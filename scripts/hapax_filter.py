#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
from collections import Counter
import argparse

# Args

args = argparse.ArgumentParser()
args.add_argument('-c', '--corpus', required=True,
                  help='csv or transcription txt file (as produced by Kaldi prep scripts.')
args.add_argument('--trans', required=False, default='transcription',
                  help='Transcription type - only required if using CSV as input file to select the appropriate transcription.')
args.add_argument('-n', required=False, default=1,
                  type=int, help='hapax threshold')
args.add_argument('-v', '--verbose', required=False, action='store_true',
                  help='verosity level')
args = args.parse_args()

########

corpus = args.corpus


def extract_vocab_from_csv(infile, transcription):
    vocab = Counter()
    with open(infile, mode='r', encoding='utf8') as inf:
        reader = csv.DictReader(inf, delimiter=',')
        for row in reader:
            for word in row[transcription].split():
                vocab[word] += 1
    return vocab


def extract_vocab_from_txt(infile):
    vocab = Counter()
    with open(infile, mode='r', encoding='utf8') as inf:
        for line in inf:
            line = line.strip().split()
            for w in line:
                vocab[w] += 1
    return vocab


if corpus.endswith('.csv'):
    vocab = extract_vocab_from_csv(corpus, args.trans)
else:
    vocab = extract_vocab_from_txt(corpus)

for w in vocab:
    if vocab[w] > args.n:
        print(w)

# hapax = len([i for i in vocab if vocab[i] == 1])
# bipax = len([i for i in vocab if vocab[i] <= 2])
# tripax = len([i for i in vocab if vocab[i] <= 3])
# dipax = len([i for i in vocab if vocab[i] <= 10])

# print("Total number of words:\t{}".format(sum(vocab.values())))
# print("Hapax legomena: \t{}".format(hapax))
# print("Bipax legomena: \t{}".format(bipax))
# print("Tripax legomena: \t{}".format(tripax))
# print("Dipax legomena: \t{}".format(dipax))


# with open(outfile, mode='w', encoding='utf8') as outf:
#     for item in vocab.keys():
#         if vocab[item] > 1:
#             outf.write('{}\n'.format(item))
