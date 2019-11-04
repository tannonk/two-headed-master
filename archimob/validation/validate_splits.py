# !/usr/bin/env python3
# -*- coding: utf8 -*-

## Author: Tannon Kew
## Email: tannon.kew@uzh.ch

"""
This script reads in audio ids from a test file and compares them against a training file to ensure that there is no overlap between the splits.

Example call:
    python3 validate_splits.py train.csv test.csv
"""

import sys
import csv

train_file = sys.argv[1]
test_file = sys.argv[2]

overlap = 0

with open(test_file, 'r', encoding='utf8') as test:
    test_reader = csv.DictReader(test, delimiter=',')
    test_utterances = [row['audio_id'] for row in test_reader]
    print('{} test utterances found in test set.'.format(len(test_utterances)))

with open(train_file, 'r', encoding='utf8') as train:
    train_reader = csv.DictReader(train, delimiter=',')
    for row in train_reader:
        if row['audio_id'] in test_utterances:
            print('WARNING: {} appears in both files'.format(row['audio_id']))
            overlap += 1

if overlap == 0:
    print('\n\t\033[92mPASSED\033[0m: no overlap found in splits.\n')
else:
    print('\n\t\033[91mFAILED\033[0m: {} items appear in both files.\n'.format(overlap))
