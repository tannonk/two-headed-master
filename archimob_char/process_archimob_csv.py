#!/usr/bin/python
#! -*- mode: python; coding: utf-8 -*-

"""
This program is a scratch attempt to go to phoneme-level
transcriptions based grapheme clusters in
manual/clusters.txt





takes as input a csv file prepared with
process_exmaralda_xml.py
and creates the files needed by the Kaldi framework to run acoustic modeling

Some processing is done on the input information:

* Filtering:
  * Chunks marked as no-relevant-speech, missing_audio, anonymity or speech-in-speech are excluded from the output
* Text processing:
  * Meta events, like hesitations, noises, ... are mapped to a smaller class
    of symbols more appropriate for training (if they weren't already when processing input XMLs!)

Note that both filtering and text processing are disabled by default, but they
can be enabled from the command line.

For details related to text processing, check the functions define_mappings and
process_transcription underneath.
"""

import sys
import argparse
import re
import csv
import unicodedata


# Default symbol to denote everything with some kind of speech structure:
# Note that it can be changed from the command line.
SPN_SYMBOL = '<SPOKEN_NOISE>'
NSN_SYMBOL = '<NOISE>'
# Symbol to denote any noise without speech structure:
SIL_SYMBOL = '<SIL_WORD>'


def get_args():
    """
    Returns the command line arguments
    """

    my_desc = 'Program that prepares the content of a csv file created with ' \
              'process_exmaralda_xml.py to train acoustic models'

    parser = argparse.ArgumentParser(description=my_desc)

    parser.add_argument('--input-csv', '-i', help='Input csv file',
                        required=True)

    parser.add_argument('--type-transcription', '-trans', help='Define the'
                        'the preferable type of transcriptions: original'
                        '(swiss) or normalized (~german)', type=str,
                        default='orig', nargs='?',
                        choices=['orig', 'norm'])

    parser.add_argument('--do-filtering', '-f', help='If given, exclude '
                        'utterances marked with no-relevant-speech or '
                        'speech-in-speech', action='store_true')

    parser.add_argument('--test-mode', '-u', help='If given, filter the '
                        'utterances considering they are aimed to testing. '
                        'Besides the actions from --do-filtering, utterances '
                        'with some word marked as unintelligible without '
                        'best guess, or truncated words, are rejected',
                        action='store_true')

    parser.add_argument('--do-processing', '-p', help='If given, transform '
                        'the events from the original transcriptions',
                        action='store_true')

    parser.add_argument('--min-duration', '-d', help='Minimum duration for an'
                        ' utterance to be accepted', type=float, default=0.0)

    parser.add_argument('--spn-word', help='Word used to represent '
                        'speech-like events (e.g. unintelligible words. '
                        'Default = {0}'.format(SPN_SYMBOL),
                        default=SPN_SYMBOL)

    parser.add_argument('--sil-word', help='Word used to represent '
                        'silence events (e.g. breathing. Default = {0}'.format(
                            SIL_SYMBOL),
                        default=SIL_SYMBOL)

    parser.add_argument('--nsn-word', help='Word used to represent '
                        'non-speech like events (e.g. [laughter], [coughing])'
                        ' Default = {0}'.format(NSN_SYMBOL),
                        default=NSN_SYMBOL)

    parser.add_argument('--output-trans', '-t', help='Output transcriptions '
                        'file', required=True)

    parser.add_argument('--clusters', '-c', help='manual/clusters.txt '
                        'file', required=False)

    parser.add_argument('--output-list', '-o', help='Output wave list. If not given, it is assumed, the processing is for the purpose of extracting clean text-level transcriptions suitable for training LM. If given the assumption is that the Kaldi training/decoding format is required.',
                        required=False)

    return parser.parse_args()


def define_mappings(spn_word, sil_word):
    """
    Creates the dictionary with the mappings for specially marked words in the
    Archimob annotations (like coughing, unintelligible, sneezing, silences,
    truncations, hesitations, assents, ...)
    This dictionary simplifies the posterior mapping of words / events to actual
    acoustic models. By default, most of the non-word events are reduced to the
    same model.
    Changes in these mappings might bring small improvements, but they also
    require coherent changes in the Kaldi scripts later (typicall, the lexicon
    and the silence phones)
    input:
        * spn_word (str): word used to represent general speech in the
          training transcriptions
        * sil_word (str): word used to represent silence-like (rather,
          non-speech) transcriptions
    returns:
        * a dictionary with the mappings.
    """

    output = {'hesitations': spn_word,
              'cough': spn_word,
              'sneeze': spn_word,
              'clear_throat': spn_word,
              'laughter': spn_word,
              'truncation': spn_word,
              'unintelligible': spn_word,
              'assent': spn_word,
              'silence': sil_word
              }

    return output


def separate_group(input_transcription):
    """
    In the Archimob annotations there can be sequences of unintelligible
    words enclosed by a single set of parentheses (v.gr: (bla bla bla)), and
    sequences of words being a part of the same comment (v.gr: [bla bla]).
    To make further processing easier, this function separates these cases
    into single word elements, like (bla) (bla) (bla)
    input:
        * input_transcription (unicode) initial transcription, potentially
          with sequences of unintellible words
    returns:
        * the transcription with split words words
    """

    verbose = False

    unint_trans = input_transcription

    if verbose:
        if re.search(r'(\([^)]+\s[^)]+\))', input_transcription):
            print 'In separate_group:'
            print '\tInput: {0}'.format(input_transcription.encode('utf8'))

    # first, unintelligible groups:
    for seq_unint in re.findall(r'(\([^)]+[\s-][^)]+\))',
                                input_transcription):
        change = re.sub(r'([^\s-]+)', r'(\g<1>)',
                        seq_unint[1:-1])

        if verbose:
            print '\tChanging {0} to {1}'.format(seq_unint.encode('utf8'),
                                                 change.encode('utf8'))

        unint_trans = unint_trans.replace(seq_unint, change, 1)

    output = unint_trans

    output = output.replace('{', '[').replace('}', ']')

    # Second, comments:
    for seq_com in re.findall(r'(\[[^]]+\])', output):
        change = re.sub(r'(\S+)', r'[\g<1>]',
                        seq_com[1:-1])

        if verbose:
            print '\tChanging {0} to {1}'.format(seq_com.encode('utf8'),
                                                 change.encode('utf8'))

        output = output.replace(seq_com, change, 1)

    return output


def process_transcription(input_trans, mappings, spn_symbol, clusters=None):
    """
    Transform certain events from the original Archimob annotations to
    something more practical for acoustic modeling
    input:
        * input_trans (unicode): a sequence of words, as taken from the
          Archimob Exmaralda files
        * mappings (dict): dictionary with the mappings for special words
        * spn_symbol (str): word to represent general speech
    * clusters mapping of clusters to use for splitting
    words to phoneme level
    returns:
        * a unicode string with the transformed annotations

    ** NOTE **
        Due to changes in process_exmaralda_xml.py, many of these normalisations have no effect. However, hesitations
    """

    verbose = False

    if verbose:
        print '\tIn process_transcription: ' \
            '{0}'.format(input_trans.encode('utf8'))

    output = input_trans

    # Some pre-changes:
    output = output.replace(u'[räuspert sich]', u'räuspern%')
    output = re.sub(ur'\(\s+\?\s+\)', '(?)', output)  # ( ? ) => (?)
    output = re.sub(ur'\(\s+', '(', output)  # (<space> => (
    output = re.sub(ur'\s+\)', ')', output)  # <space>) => )
    output = re.sub(ur'veg\$sse', ur'vegässe', output)  # Typo
    output = re.sub(ur'vorh\$r', ur'vorhär', output)  # Typo
    output = output.replace(u'lacht %', u'lacht%')

    # Separate the unintelligible groups:
    output = separate_group(output)

    # All (hopefully...) hesitation markers from Archimob:
    # 19.11.19: added new items to this set - u'hmhmhmhm', u'hmhm', u'hmhmhm', u'mh'
    hesitation_set = set([u'ah', u'eh', u'eh', u'hmm', u'ähm',
                          u'ääm', u'ää', u'ehm', u'äwr', u'mhm',
                          u'ähä', u'ä', u'ww', u'pff', u'hm',
                          u'k', u'hä', u'aha', u'ähä', u'mpf',
                          u'm', u'aa', u'äh', u'äw', u'e', u'mh',
                          u'mhmh', u'w', u'hmhmhmhm', u'hmhm', u'hmhmhm',
                          u'ää', u'äää', u'äääää', u'ääääääää', u'ääm',
                          u'äämm', u'mm', u'mmm', u'üüü', u'ee', u'eee',
                          u'fff', u'ssss', u'ehm', u'eh'])

    interm = []
    for token in output.split():

        if token == u'/':
            # Silence:
            interm.append(mappings['silence'])
        elif u'/' in token:
            # Truncation:
            interm.append(mappings['truncation'])
        elif u'(?)' in token:
            # Unintelligible without best guess:
            interm.append(mappings['unintelligible'])
        elif token in hesitation_set or re.match(ur'.+\$\)*$', token):
            # It is a hesitation:
            interm.append(mappings['hesitations'])
        elif re.match(ur'^\(.+', token) or re.match(ur'\)$', token):
            # Unintelligible with best guess:
            interm.append(re.sub(ur'[()]', '', token))
        elif token == u'/hmhm/' or token == u'mhm' or token == u'aha':
            # An assent:
            interm.append(mappings['assent'])
        elif re.match(ur'huste[nt]%', token) or \
                re.match(ur'\[hustet\]', token):
            # Coughing:
            interm.append(mappings['cough'])
        elif token == u'niesst' or token == u'niesst%':
            # Sneezing:
            interm.append(mappings['sneeze'])
        elif token == u'räuspern%':
            # Clear throat:
            interm.append(mappings['clear_throat'])
        elif token == u'lacht%' or token == '[lacht]':
            # Laughter:
            interm.append(mappings['laughter'])
        elif u'[' in token or u']' in token:  # re.match(ur'[[{].+', token):
            # Not a lot of coherence here: comments which should probably be
            # ignored, words in other languages... Let's map it to SPN_SYMBOL,
            # and cross our fingers
            interm.append(spn_symbol)
        elif re.match(ur'.+\+$', token):
            # Anonymization:
            interm.append(token.replace('+', ''))
        elif token == u'-':
            # A single hyphen. Probably an annotation error. Ignore it:
            pass
        else:
            interm.append(token)

    output = u' '.join(interm)

    # Do general normalization:
    # Delete commas:
    output = output.replace(',', '')
    # Delete periods:
    output = output.replace('.', '')
    # Delete question marks:
    output = output.replace('?', '')
    # Delete parentheses
    output = output.replace('(', '')
    output = output.replace(')', '')

    # convert to list
    # output = output.split()
    # print output
    new_out = []
    for w in output.split():
        if w in [u'<SPOKEN_NOISE>', u'<SIL_WORD>', u'<NOISE>']:
            # print w
            new_out.append(w)
            # print new_out
        else:
            new_out.append(transcribe_simple(w, clusters))
    # output = [transcribe_simple(w, clusters) for w in output.split()]
    output = u' <w> '.join(new_out)
    # print output

    if verbose:
        print '\t\tOutput: {0}'.format(output.encode('utf8'))

    return output


# def transcribe_simple(word, clusters, max_length_cluster, map_diacritic=None, verbose=False):
def transcribe_simple(word, clusters, map_diacritic=None, verbose=False):
    """
    Transcribes a word mapping each grapheme to itself, besides some special clusters
    input:
        * word (str): Input word
        * cluster (dict): Dictionary mapping clusters of graphemes to single
          phones
        * max_length_cluster (int): maximum length of all the consonant
          clusters
    returns:
        * a string with a pseudo phonetic transcription of the input word
    """

    # Signs to exclude from the transcriptions (when --add-signs is not specified)
    EXCLUDE_SET = set(["'", '-', '.'])

    max_length_cluster = get_max_length(clusters)

    word = ProcessUnicodeCompounds(word, map_diacritic)

    # print word

    word_length = len(word)

    output = ['']

    graph_index = 0

    while graph_index < word_length:

        if word[graph_index] in EXCLUDE_SET:
            if verbose:
                print('skipping "{0}" ...'.format(word[graph_index]))
            graph_index += 1
            continue

        transcribed = 0

        for index in range(graph_index + max_length_cluster - 1,
                           graph_index, -1):

            if verbose:
                print('\tIndex = {0}. Graph = {1}. Length = {2}'.format(
                    index, graph_index, word_length))

            if index >= word_length:
                continue

            current_clust = ''.join(word[graph_index:index+1])

            if verbose:
                print('\tLooking for cluster {}'.format(
                    current_clust.encode('utf8')))

            if current_clust in clusters:

                if verbose:
                    print('\tFound "{}" ...'.format(
                        current_clust.encode('utf8')))

                interm_output = []
                for trans in clusters[current_clust]:
                    for multi in output:
                        interm_output.append(multi+' '+trans)

                output = interm_output

                graph_index += len(current_clust)
                transcribed = 1
                break

        if transcribed == 0:
            interm_output = []
            for multi in output:
                interm_output.append(multi + ' ' + word[graph_index])
            output = interm_output
            # output = output + ' ' + word[graph_index]

            graph_index += 1

            if verbose:
                for multi in output:
                    print('\tNo cluster: {}'.format(multi.encode('utf8')))

    # if verbose:
    #     print('Output: {}'.format(','.join(output)))

    # print output

    # return [multi.strip() for multi in output]
    return output[0]


def get_max_length(clusters_dict):
    """
    Calculates the maximum cluster length given the input 'clusters_dict'
    """
    max_length_cluster = 0
    for clust in clusters_dict:
        if len(clust) > max_length_cluster:
            max_length_cluster = len(clust)
    return max_length_cluster


def read_clusters(input_file):
    """
    Reads the file with the clusters
    input:
        * input_file (str) name of the input file, with the consonant
          clusters and their mappings to some phoneme name ("cluster" "phone")
    returns:
        * a dictionary with the clusters as keys, and the corresponding phones
          as values
    """

    verbose = False

    output = {}

    try:
        input_f = open(input_file, 'r')
    except IOError as err:
        sys.stderr.write('Error opening {0} ({1})\n'.format(input_file, err))
        sys.exit(1)

    if verbose:
        print 'In read_clusters:'

    for line in input_f:

        if verbose:
            print '\tLine = ' + line

        line = line.decode('utf8').rstrip()
        fields = re.split(r'\t', line)

        if len(fields) != 2:
            sys.stderr.write('Error: the file {0} must have exactly two '
                             'columns separated by tabs. '
                             'See {1}\n'.format(input_file, line))
            sys.exit(1)

        output[fields[0]] = re.split(r'\s*,\s*', fields[1])

        if verbose:
            print '\t' + '-'.join(re.split(r'\s*,\s*', fields[1])) + '\n'

    input_f.close()

    return output


def ProcessUnicodeCompounds(data, map_diacritic=None):
    """
    Correctly re-combines compound unicode characters.
    input:
        * data (str|list) Input unicode data. String or list.
        * map_diacritic (None|unicode) Unicode string to map all combining
          characters to.  Default to original character.
    returns:
        * a list of unicode characters, where all compounds have been
          recombined, either using the original, or the map_diacritic value.
    """
    for char in data:
        if not isinstance(char, unicode):
            raise TypeError, 'All chars in data must be ' \
                'valid unicode instances!'

    if map_diacritic != None and \
       not isinstance(map_diacritic, unicode):
        raise TypeError, 'map_diacritic MUST be None ' \
            'or a valid unicode string.'

    # Split into individual characters (not graphemes!)
    # it is necessary to recombine once, just in case the user
    # provided a list
    chars = [char for char in u''.join(data)]

    # Recombine unicode compounds. NOTE: unicodedata.normalize
    # does NOT cover all examples in the data, so we have to
    # do this manually.  The compound diacritics always follow
    # the letter they combine with.
    chars.reverse()
    chunk = []
    tmp_chars = []
    for char in chars:
        if unicodedata.combining(char):
            if map_diacritic:
                chunk.append(map_diacritic)
            else:
                chunk.append(char)
        else:
            chunk.append(char)
            chunk.reverse()
            tmp_chars.append(u''.join(chunk))
            chunk = []
    # After successful recombination we finally have a list
    # of actual graphemes
    chars = [char for char in tmp_chars]
    chars.reverse()

    return chars


def main():
    """
    Main function from the program
    """

    verbose = False

    # Get the command line arguments:
    args = get_args()

    # Define the mappings  dictionary:
    mappings = define_mappings(args.spn_word, args.sil_word)

    if args.clusters:
        clusters = read_clusters(args.clusters)
    else:
        clusters = None

    # Open the input file:
    try:
        input_f = open(args.input_csv, 'r')
    except IOError as err:
        sys.stderr.write('Error opening {0} ({1})\n'.format(args.input_csv,
                                                            err))
        sys.exit(1)

    # Create the output files:
    try:
        output_t = open(args.output_trans, 'w')
    except IOError as err:
        sys.stderr.write('Error creating {0} ({1})\n'.format(args.output_trans,
                                                             err))
        sys.exit(1)

    if args.output_list:
        try:
            output_l = open(args.output_list, 'w')
        except IOError as err:
            sys.stderr.write('Error creating {0} ({1})\n'.format(args.output_list,
                                                                 err))
            sys.exit(1)

    csv_reader = csv.reader(input_f)
    n_filtered = 0

    for index, row in enumerate(csv_reader):

        if index == 0:
            header = row
            header_size = len(row)
            continue

        if len(row) != header_size:
            print(row)
            sys.stderr.write('Error reading {0}: different number of elements'
                             ' in header ({1}), and line {2} '
                             '({3})\n'.format(args.input_csv, header_size,
                                              index, len(row)))
            sys.exit(1)

        data_dict = {key: value.decode('utf8')
                     for key, value in zip(header, row)}

        # if float(data_dict['duration']) <= args.min_duration:
        #     print '\tSkipping {0}: duration = {1}'.format(data_dict['utt_id'],
        #                                                   data_dict['duration'])
        #     continue

        if args.type_transcription == 'norm':
            transcription = data_dict['normalized']
        else:
            # original Dieth transcription
            transcription = data_dict['transcription']

        # Check filtering:
        if args.do_filtering or args.test_mode:
            if int(data_dict['anonymity']) == 1 or \
                    int(data_dict['speech_in_speech']) == 1 or \
                    int(data_dict['missing_audio']) == 1 or \
                    int(data_dict['no_relevant_speech']) == 1:
                n_filtered += 1
                if verbose:
                    print '\tFiltering {0}. anonym={1};' \
                        ' sp_in_sp={2};' \
                        ' non_sp{3};' \
                        ' non_sp{4}'.format(data_dict['utt_id'],
                                            data_dict['anonymity'],
                                            data_dict['speech_in_speech'],
                                            data_dict['missing_audio'],
                                            data_dict['no_relevant_speech'])
                continue

        # 19.11.19: this no longer does anything, since items are already preprocessed in process_exmaralda_xml.py
        if args.test_mode:
            # Check unintelligible words without best guess:
            if re.search(ur'\(\s*\?*\s*\)', transcription):
                if verbose:
                    print '\tFiltering {0} (unintelligible ' \
                        'word)'.format(data_dict['utt_id'])
                continue
            # Truncated words:
            if (re.search(ur'\w/', transcription) or
                    re.search(ur'/\w', transcription)):
                if verbose:
                    print '\tFiltering {0} (truncated ' \
                        'word)'.format(data_dict['utt_id'])
                continue

        if args.do_processing:
            # Process text:
            transcription = process_transcription(
                transcription, mappings, args.spn_word, clusters)
            # If do preprocessing is NOT TRUE, we keep the original one as it is.
            # You probably do not want to do this...

        if args.output_list:  # if user has specified a wav list file as output argument, assume format should match kaldi expected input format
            # Write the transcriptions file:
            output_t.write('{0}\t{1}\n'.format(data_dict['utt_id'],
                                               transcription.encode('utf8')))

            # Write the utterance list:
            output_l.write('{0}\n'.format(data_dict['utt_id']))

        else:  # otherwise, we assume the user wants just the clean transcriptions which are suitable for training a language model
            # in this case, filter out meta tags <SPOKEN_NOISE>, <SIL_WORD>, <NOISE>
            transcription = re.sub(ur'<SPOKEN_NOISE>\s?(<w>)?', u'', transcription)
            transcription = re.sub(ur'<SIL_WORD>\s?(<w>)?', u'', transcription)
            transcription = re.sub(ur'<NOISE>\s?(<w>)?', u'', transcription)
            transcription = re.sub(ur'\s+', u' ', transcription.strip())
            if transcription:
                output_t.write('{}\n'.format(transcription.encode('utf8')))

    # if verbose:
    print("{} transcriptions were filtered out while processing archimob csv.\n".format(n_filtered))

    input_f.close()
    output_t.close()
    if args.output_list:
        output_l.close()


if __name__ == '__main__':
    main()
