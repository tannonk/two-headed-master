#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
This program is a modification of the original provided by Fran. It creates a simple lexicon with a one to one grapheme to phoneme mapping, besides some consonant clusters that are known to map to a single phone.

If provided with a JSON dictionary of normalised to Dieth forms, it is expected to produced a lexicon for normalised transcriptions.
"""

import sys
import re
import argparse
import unicodedata
import json
from collections import Counter

# Signs to exclude from the transcriptions (when --add-signs is not specified)
EXCLUDE_SET = set(["'", '-', '.'])


def get_args():
    """
    Returns the command line arguments
    """

    parser = argparse.ArgumentParser(
        description='Generates pronunciations for an input vocabulary by mapping clusters of graphemes to phonetic symbols')

    parser.add_argument('--vocabulary', '-v', help='Input vocabulary',
                        required=True)

    parser.add_argument('--cluster-file', '-c',
                        help='File with the consonant clusters', required=False)

    parser.add_argument('--n2d', '-d', required=False,
                        help='If provided, lexicon is created with a mapping from normalised to Dieth transcription forms. JSON file is expected')

    parser.add_argument('--map-diacritic', '-m', required=False,
                        help='Map compound diacritics to alternative character. If null, just recombines', default=None)

    parser.add_argument('--output-file', '-o', help='Output lexicon',
                        required=True)

    parser.add_argument('--verbose', required=False,
                        action='store_true', help='Print progress to stdout.')

    args = parser.parse_args()

    if not args.map_diacritic:
        args.map_diacritic = None

    return args


def process_unicode_compounds(data, map_diacritic=None):
    """
    Correctly re-combines compound unicode characters.

    Args:
        * data (str|list) Input unicode data. String or list.
        * map_diacritic (None|unicode) Unicode string to map all combining characters to. Default to original character.
    Returns:
        list of unicode characters, where all compounds have been recombined, either using the original, or the map_diacritic value.
    """

    # print(daa)
    for char in data:
        if not isinstance(char, str):
            raise(TypeError, 'All chars in data must be valid unicode instances!')

    if map_diacritic != None and not isinstance(map_diacritic, str):
        raise(TypeError, 'map_diacritic MUST be None or a valid unicode string.')

    # Split into individual characters (not graphemes!)
    # it is necessary to recombine once, just in case the user provided a list
    chars = [char for char in ''.join(data)]

    # Recombine unicode compounds.
    # NOTE: unicodedata.normalize does NOT cover all examples in the data, so we have to
    # do this manually.
    # The compound diacritics always follow the letter they combine with.
    chars.reverse()
    chunk = []
    tmp_chars = []
    for char in chars:
        # check if characters has a combined diactritic
        if unicodedata.combining(char):
            if map_diacritic:
                chunk.append(map_diacritic)
                # print(chars)
            else:
                # remove additional diacritics (they are used inconsistently anyway!)
                pass
                # chunk.append(char)
        else:
            chunk.append(char)
            chunk.reverse()
            tmp_chars.append(''.join(chunk))
            chunk = []

    # After successful recombination we finally have a list of actual graphemes
    chars = [char for char in tmp_chars]
    chars.reverse()

    return chars


def get_max_length(clusters_dict):
    """
    Calculates the maximum cluster length given the input 'clusters_dict'
    """
    max_length_cluster = 0
    for clust in clusters_dict:
        if len(clust) > max_length_cluster:
            max_length_cluster = len(clust)
    return max_length_cluster


def read_clusters(clusters_file, verbose=False):
    """
    Reads the file with the clusters
    input:
        * input_file (str) name of the input file, with the consonant clusters and their mappings to some phoneme name ("cluster" "phone")
    returns:
        * a dictionary with the clusters as keys, and the corresponding phones as values
    """

    output = {}

    with open(clusters_file, 'r', encoding='utf8') as inf:

        if verbose:
            print('In read_clusters:')

        for line in inf:

            if verbose:
                print('\tLine = ' + line)

            fields = line.rstrip().split('\t')

            if len(fields) != 2:
                sys.stderr.write(
                    'Error: the file {0} must have exactly two columns separated by tabs. Check {1}\n'.format(input_file, line))
                sys.exit(1)

            output[fields[0]] = fields[1].split()

            if verbose:
                print('\t{}'.format('-'.join(fields[1].split())))

    return output


def transcribe_simple(word, clusters, max_length_cluster, map_diacritic=None, verbose=False):
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

    word = process_unicode_compounds(word, map_diacritic)
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
                print('\tLooking for cluster {}'.format(current_clust))

            if current_clust in clusters:

                if verbose:
                    print('\tFound "{}" ...'.format(current_clust))

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
                    print('\tNo cluster: {}'.format(multi))

    if verbose:
        print('Output: {}'.format(','.join(output)))

    return [multi.strip() for multi in output]


def main():
    """
    Main function of the program
    """

    # Get the command line arguments:
    args = get_args()

    # clusters = read_clusters(args.cluster_file)
    # max_length_cluster = get_max_length(clusters)

    try:
        input_f = open(args.vocabulary, 'r', encoding='utf8')
    except IOError as err:
        sys.stderr.write(
            'Error opening {0} ({1})\n'.format(args.vocabulary, err))
        sys.exit(1)

    try:
        output_f = open(args.output_file, 'w', encoding='utf8')
    except IOError as err:
        sys.stderr.write(
            'Error creating {0} ({1})\n'.format(args.output_file, err))
        sys.exit(1)

    for w in input_f:
        w = w.strip()
        if w:
            output_f.write('{} {}\n'.format(w.strip(), w.strip()))

    output_f.close()
    input_f.close()


if __name__ == '__main__':
    main()
