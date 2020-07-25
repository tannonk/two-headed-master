#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Example call:

    python3 my_scripts/get_frequency_vocabulary.py /mnt/data/archimob_r2/archimob_r2.csv vocab.txt original
"""

import sys
import csv
import json
from collections import Counter

infile = sys.argv[1]
outfile = sys.argv[2]
if len(sys.argv) > 3:
    trans = sys.argv[3]

def extract_vocab_from_csv(infile, outfile, transcription='transcription'):
    vocab = Counter()
    with open(infile, mode='r', encoding='utf8') as inf:
        reader = csv.DictReader(inf, delimiter=',')
        for row in reader:
            for word in row['transcription'].split():
                vocab[word] += 1
    with open(outfile, mode='w', encoding='utf8') as outf:
        for item in vocab.keys():
            if vocab[item] > 1:
                outf.write('{}\n'.format(item))


def extract_vocab_from_json(infile, outfile):

    with open(infile, mode='r', encoding='utf8') as inf:
        vocab = json.load(inf, encoding='utf8')
    with open(outfile, mode='w', encoding='utf8') as outf:
        for item in vocab.keys():
            outf.write('{}\n'.format(item))


def main():
    if infile.endswith('.csv'):
        extract_vocab_from_csv(infile, outfile, trans)
    elif infile.endswith('.json'):
        extract_vocab_from_json(infile, outfile)

if __name__ == '__main__':
    main()
