#!/usr/bin/python3
#! -*- coding: utf-8 -*-

"""
This program creates a simple lexicon for the normalised transcription of Archimob. The pronunciations are based on a one-to-one grapheme to phoneme mapping, except for some consonant clusters that are known to map to a single phone.

Example call:
    python3 my_scripts/create_normalised_lexicon.py \
    -v processed/exp1/normalised_vocabulary.txt \
    -c /home/tannon/kaldi_wrk/two-headed-master/manual/clusters.txt \
    --n2d archi_data/norm2dieth.json \
    -o normalised_lexicon.txt

"""

import sys
import re
import argparse
import json
import unicodedata

# Signs to exclude from the transcriptions (when --add-signs is not specified)
EXCLUDE_SET = set(["'", '-', '.', '==', '*'])

def get_args():
    """
    Returns the command line arguments
    """

    my_desc = 'Generates pronunciations for a normalised input vocabulary by mapping normalised forms to dieth transcriptions and a, primarily, one-to-one mapping from graphemes to phonetic symbols'

    parser = argparse.ArgumentParser(description=my_desc)

    parser.add_argument('--vocabulary', '-v', required=True, help='Input vocabulary')

    parser.add_argument('--cluster-file', '-c', required=True, help='File with the consonant clusters')

    parser.add_argument('--n2d', required=True, help='Normalised to Dieth transcription mapping. JSON file is expected')

    parser.add_argument('--map-diacritic', '-m', required=False, action='store_true', help='Map compound diacritics to alternative character. If null, just recombines')

    parser.add_argument('--output-file', '-o', required=True, help='Output lexicon')

    parser.add_argument('--verbose', required=False, action='store_true', help='Print progress to stdout.')


    args = parser.parse_args()

    return args


def ProcessUnicodeCompounds(data, map_diacritic=False):
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
        if not isinstance(char, str):
            raise TypeError('All chars in data must be valid strings!')

    if map_diacritic and not isinstance(map_diacritic, str):
        raise TypeError('map_diacritic MUST be False or a valid unicode string.')

    # Split into individual characters (not graphemes!)
    # it is necessary to recombine once, just in case the user
    # provided a list
    chars = [char for char in ''.join(data)]

    # Recombine unicode compounds. NOTE: unicodedata.normalize
    # does NOT cover all examples in the data, so we have to
    # do this manually. The compound diacritics always follow
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
            tmp_chars.append(''.join(chunk))
            chunk = []
    # After successful recombination we finally have a list of actual graphemes
    chars = [char for char in tmp_chars]
    chars.reverse()

    return chars


def read_clusters(input_file, verbose=False):
    """
    Reads the file with the clusters
    input:
        * input_file (str) name of the input file, with the consonant
          clusters and their mappings to some phoneme name ("cluster" "phone")
    returns:
        * a dictionary with the clusters as keys, and the corresponding phones
          as values
    """

    output = {}

    try:
        with open(input_file, 'r', encoding='utf8') as input_f:

            if verbose:
                print('In read_clusters:')

            for line in input_f:

                line = line.rstrip()
                fields = re.split(r'\t', line)

                if verbose:
                    print('\tLine = ' + line)

                if len(fields) != 2:
                    sys.stderr.write('Error: the file {0} must have exactly two columns separated by tabs. See {1}\n'.format(input_file, line))
                    sys.exit(1)

                output[fields[0]] = re.split(r'\s*,\s*', fields[1])

                if verbose:
                    print('\t' + '-'.join(re.split(r'\s*,\s*', fields[1])) + '\n')

    except IOError as err:
        sys.stderr.write('Error opening {0} ({1})\n'.format(input_file, err))
        sys.exit(1)


    return output

def transcribe_simple(word, clusters, max_length_cluster, map_diacritic=False, verbose=False):
    """
    Transcribes a word mapping each grapheme to itself, besides some special
    clusters
    input:
        * word (str): Input word
        * cluster (dict): Dictionary mapping clusters of graphemes to single
          phones
        * max_length_cluster (int): maximum length of all the consonant
          clusters
    returns:
        * a string with a pseudo phonetic transcription of the input word
    """

    word = ProcessUnicodeCompounds(word, map_diacritic)
    word_length = len(word)

    output = ['']

    graph_index = 0

    if verbose:
        print('Input word: ' + word)
        import pdb
        pdb.set_trace()

    while graph_index < word_length:

        if word[graph_index] in EXCLUDE_SET:
            if verbose:
                print('Found sign {0}: skipping it.'.format(word[graph_index]))
            graph_index += 1
            continue

        transcribed = 0

        for index in range(graph_index + max_length_cluster - 1,
                           graph_index, -1):

            if verbose:
                print('\tIndex = {0}. Graph = {1}. Length = {2}'.format(index, graph_index, word_length))

            if index >= word_length:
                continue

            current_clust = ''.join(word[graph_index:index + 1])

            if verbose:
                print('\tLooking for cluster ' + current_clust)

            if current_clust in clusters:

                if verbose:
                    print('\tFound ' + current_clust)

                interm_output = []
                for trans in clusters[current_clust]:
                    for multi in output:
                        interm_output.append(multi + ' ' + trans)

                output = interm_output

                #    output = output + ' ' + clusters[current_clust]
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
                    print('\tNo cluster: ' + multi)

    if verbose:
        print('Output: ' + ','.join(output))

    return [multi.strip() for multi in output]


def main():
    """
    Main function of the program
    """

    # Get the command line arguments:
    args = get_args()

    clusters = read_clusters(args.cluster_file)

    max_length_cluster = 0
    for clust in clusters:
        if len(clust) > max_length_cluster:
            max_length_cluster = len(clust)


    try:
        with open(args.n2d, 'r', encoding='utf8') as norm2dieth_file:
            n2d_map = json.load(norm2dieth_file)

    except IOError as err:
        sys.stderr.write('Error opening {0} ({1})\n'.format(args.n2d, err))
        sys.exit(1)


    try:
        with open(args.vocabulary, 'r', encoding='utf8') as input_f, open(args.output_file, 'w', encoding='utf8') as output_f:

            for word in input_f:

                word = word.rstrip()
                if isinstance(args.map_diacritic, str):
                    args.map_diacritic = args.map_diacritic

                dieth_forms = n2d_map.get(word)
                # dieth_forms = n2d_map.get(word.replace('_', ' '))

                # if args.verbose:
                #     print(word, dieth_forms)

                if dieth_forms:
                    for w in dieth_forms:
                        # print(w)
                        transcription = transcribe_simple(w.lower(),
                                                          clusters,
                                                          max_length_cluster,
                                                          args.map_diacritic)
                        # print(transcription)

                        for multi in transcription:
                            output_f.write('{0} {1}\n'.format(word, multi))
                else:
                    print('\tNo Dieth forms for {}'.format(word))

    except IOError as err:
        sys.stderr.write('Error opening file ({1})\n'.format(err))
        sys.exit(1)




if __name__ == '__main__':
    main()
