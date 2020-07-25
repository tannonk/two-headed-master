#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
python3 lexicon_coverage.py lexicon texts

eg.

python3 my_scripts/lexicon_coverage.py \
    corpus_data/norm2sampa_zrh.json \
    processed/archimob_r2/sampa/am_out/initial_data/data/transcriptions.txt
"""

import sys
import json
import csv
from collections import Counter, defaultdict
import argparse

# Args

args = argparse.ArgumentParser()
args.add_argument('-l', '--lexicon', required=True,
                  help='json or txt file containing surface forms mapped to their pronunciation string.')
args.add_argument('-c', '--corpus', required=True,
                  help='csv or transcription txt file (as produced by Kaldi prep scripts.')
args.add_argument('--trans', required=False, default='transcription',
                  help='Transcription type - only required if using CSV as input file to select the appropriate transcription.')
args.add_argument('-v', '--verbose', required=False, action='store_true',
                  help='verosity level')
args = args.parse_args()

########

lexicon = args.lexicon
corpus = args.corpus
verbose = args.verbose


# collect pronunciation lexicon as lexicon
print("\nCollecting pronunciation dictionary...")
if lexicon.endswith('.json'):
    with open(lexicon, 'r', encoding='utf8') as f:
        lexicon_dict = json.load(f)

elif lexicon.endswith('.txt'):
    lexicon_dict = defaultdict(list)
    with open(lexicon, 'r', encoding='utf8') as f:
        for line in f:
            line = line.strip().split()
            word = line[0]
            pron = ' '.join(line[1:])
            lexicon_dict[word].append(pron)

# collect corpus words as vocab
print("\nCollecting vocabulary from transcriptions...")
vocab = Counter()
if corpus.endswith('.csv'):
    with open(corpus, 'r', encoding='utf8') as f:
        reader = csv.DictReader(f, delimiter=',')
        for row in reader:
            filters = [
                row['anonymity'],
                row['speech_in_speech'],
                row['missing_audio'],
                row['no_relevant_speech']
            ]
            if '1' not in filters:
                for w in row[args.trans].split():
                    vocab[w] += 1
else:
    with open(corpus, 'r', encoding='utf8') as f:
        for line in f:
            line = line.strip().split()
            for w in line:
                if w and not w[0].isdigit():
                    vocab[w] += 1


print("\nCalculating coverage...")
v = set(vocab.keys())
l = set(lexicon_dict.keys())
intersection = v.intersection(l)
diff = v.difference(l)

if verbose:
    print("\nVocab items missing:")
    for w in diff:
        print(w)
    print()

print("Vocab length:", len(v))
print("Lexicon length:", len(l))
print("Intersection:", len(intersection))
print("Difference:", len(diff))
print("OOV:")
print((len(diff)/len(v)*100))
print("Coverage:")
print((len(intersection)/len(v)*100))

# missing = set()
# for w in vocab:
#     if not w in lexicon_dict.keys():
#         missing.add(w)
# print(len(missing))
# print(missing)

#     # if vocab[w] > n and w not in sampa.keys():
#         # print(w)

# print("Vocab length:", v_length)
# print("Vocab length:", v_length)
# print("Words missing:", c)
# print(((v_length-c)/v_length)*100)

# print("Threshold:", n)

# with open(sampa_file, 'r', encoding='utf8') as f:
#     sampa = json.load(f)

# with open(csv_file, 'r', encoding='utf8') as f:
#     reader = csv.DictReader(f, delimiter=',')
#     for row in reader:
#         for w in row['normalized'].split():
#             vocab_count[w] += 1


# def ttr(d):
#     toks = sum(d.values())
#     types = len(d.keys())
#     return types/toks

# print(ttr(vocab_count))

# c = 0
# for w in vocab_count.keys():
#     if w in sampa:
#         if c == 0:
#             c = vocab_count[w]
#         elif vocab_count[w] < c:
#             c = vocab_count[w]

# print(c)
