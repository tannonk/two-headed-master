#!/usr/bin/python3
#! -*- coding: utf-8 -*-

"""
This program creates a lexicon using SAMPA transcriptions.

Example call:
    python3 create_sampa_normalised_lexicon.py -s norm2sampa.json -v normalised_vocabulary.txt -o normalised_lexicon.txt

"""

import sys
import argparse
from pathlib import Path
import json
from collections import Counter

def get_args():
    """
    Returns the command line arguments
    """

    my_desc = 'Generates pronunciations for an input vocabulary based on SAMPA data provided by URPP and Swisscom'

    parser = argparse.ArgumentParser(description=my_desc)

    parser.add_argument('--vocabulary', '-v', required=True, help='Input vocabulary')

    parser.add_argument('--sampa_file', '-s', required=True, help='JSON file containing dictionary of normalised words and their SAMPA pronunciations')

    parser.add_argument('--outfile', '-o', help='Output lexicon', required=True)

    args = parser.parse_args()

    return args

def write_lexicon(vocab, outfile, sampa_dict):
    """
    Side effects: produces output file equivalent to 'lexicon.txt'. Multiple pronunciations for the same word are written to their own lines.
    format:
        <word> <pronunciation>

    ** Note **
        words containing multiple tokens in the input vocabulary are expected to be glued together with '_'.
    """

    no_pron = Counter()
    line_c = 0
    c = 0
    with open(vocab, 'r', encoding='utf8') as inf, open(outfile, 'w', encoding='utf8') as outf:
        for line in inf:
            line_c += 1
            vocab_word = line.strip()
            prons = sampa_dict.get(vocab_word)
            if prons:
                c += 1
                for pron in prons:
                    outf.write('{} {}\n'.format(vocab_word, pron))
            else:
                no_pron[vocab_word] += 1

    print('{} items in vocabulary of length {} have at least 1 pronunciation. ({:.2f}%)'.format(c, line_c, c/line_c*100))

    #
    # with open(overflow_file, 'w', encoding='utf8') as overflow:
    #     print('Writing overflow words to {}'.format(overflow_file))
    #     for k, v in no_pron.items():
    #         overflow.write('{}\t{}\n'.format(k, v))


def main():

    args = get_args()

    with open(args.sampa_file, 'r', encoding='utf8') as f:
        sampa_dict = json.load(f, encoding='utf8')

    write_lexicon(args.vocabulary, args.outfile, sampa_dict)

if __name__ == '__main__':
    main()
