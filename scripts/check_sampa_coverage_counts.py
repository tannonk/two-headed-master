#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Example call:

    python3 /home/tannon/my_scripts/check_sampa_coverage.py /mnt/tannon/corpus_data/norm2sampa.json /mnt/tannon/corpus_data/csv_files/archimob_r1/train.csv

    python3 /home/tannon/my_scripts/check_sampa_coverage.py /mnt/tannon/corpus_data/norm2sampa.json /mnt/tannon/processed/archimob_r1/norm/am_out/initial_data/tmp/vocabulary.txt
"""

import sys
import json
import csv
from collections import Counter

sampa_file = sys.argv[1]
csv_file = sys.argv[2]
if len(sys.argv) > 3:
    n = int(sys.argv[3])
else:
    n = 1

vocab_count = Counter()

# if csv_file.endswith('.csv'):
#     with open(csv_file, 'r', encoding='utf8') as f:
#         reader = csv.DictReader(f, delimiter=',')
#         for row in reader:
#             for w in row['normalized'].split():
#                 vocab_count[w] += 1

# with open(sampa_file, 'r', encoding='utf8') as f:
#     sampa = json.load(f)

# c = 0
# for w in vocab_count:
#     if vocab_count[w] > n and w not in sampa.keys():
#         print(w)
#         c += 1

# print("Vocab length:", len(vocab_count))
# print("Words missing:", c)
# print("Threshold:", n)

with open(sampa_file, 'r', encoding='utf8') as f:
    sampa = json.load(f)

with open(csv_file, 'r', encoding='utf8') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        for w in row['normalized'].split():
            vocab_count[w] += 1


def ttr(d):
    toks = sum(d.values())
    types = len(d.keys())
    return types/toks


print(ttr(vocab_count))

# c = 0
# for w in vocab_count.keys():
#     if w in sampa:
#         if c == 0:
#             c = vocab_count[w]
#         elif vocab_count[w] < c:
#             c = vocab_count[w]

# print(c)
