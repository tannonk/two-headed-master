#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Example call:

    python3 /home/tannon/my_scripts/compare_vocabulary_with_csv.py /mnt/tannon/processed/archimob_r1/norm/am_out/initial_data/tmp/vocabulary.txt /mnt/tannon/corpus_data/csv_files/archimob_r1/train.csv
"""

import sys
import csv

vocab_file = sys.argv[1]
csv_file = sys.argv[2]

vocabulary = set()

with open(vocab_file, 'r', encoding='utf8') as f:
    for w in f:
        w = w.strip()
        # print(w)
        vocabulary.add(w)

overlap = set()
overflow = set()

with open(csv_file, 'r', encoding='utf8') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        for w in row['normalized'].split():
            # print(w)
            if w in vocabulary:
                overlap.add(w)
            else:
                overflow.add(w)


print('Vocabulary length: {}'.format(len(vocabulary)))
print('Normalised types covered in vocabulary: {}'.format(len(overlap)))
print('Normalised types NOT covered in vocabulary: {}'.format(len(overflow)))
if len(overflow) > 0:
    print(overflow)

# the vocabulary created in process_archimob_csv extracts words only from non-filtered utterances!
