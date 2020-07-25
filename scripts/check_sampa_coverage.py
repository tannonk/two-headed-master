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
vocab_file = sys.argv[2]

with open(sampa_file, 'r', encoding='utf8') as f:
    sampa = json.load(f)

overlap = Counter()
overflow = Counter()

filter_columns = ['anonymity', 'speech_in_speech', 'missing_audio', 'no_relevant_speech']

if vocab_file.endswith('.csv'):
    with open(vocab_file, 'r', encoding='utf8') as f:
        reader = csv.DictReader(f, delimiter=',')
        for row in reader:

            filter_values = [row[i] for i in filter_columns]

            # if one of the 4 cells contains a 1, the utterance is will be filtered, continue on the next row of the file
            if '1' in filter_values:
                pass
            else:
                for w in row['normalized'].split():
                    # print(w)
                    if w in sampa.keys():
                        overlap[w] += 1
                    else:
                        overflow[w] += 1

elif vocab_file.endswith('.txt'):
    with open(vocab_file, 'r', encoding='utf8') as f:
        for w in f:
            w = w.strip()
            if w in sampa.keys():
                overlap[w] += 1
            else:
                overflow[w] += 1


print('Sampa length: {}'.format(len(sampa)))
print('Vocabulary length: {}'.format(len(overlap)+len(overflow)))
print('Normalised types covered: {}'.format(len(overlap)))

print('Normalised types NOT covered: {}'.format(len(overflow)))
if vocab_file.endswith('.csv'):
    print(overlap.most_common(20))
    print(overflow.most_common(20))
