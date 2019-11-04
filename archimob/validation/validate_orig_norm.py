#!/usr/bin/python3
# -*- coding: utf-8 -*-

## Author: Tannon Kew
## Email: tannon.kew@uzh.ch

"""
Checks the length of Dieth transcriptions and normalised transcriptions in a csv file.
Passes if token length of both transcriptions match.

Example call:

    validate_orig_norm.py train.csv
"""

import sys
import csv

filter_columns = ['anonymity', 'speech_in_speech', 'missing_audio', 'no_relevant_speech']

c = 0

with open(sys.argv[1], 'r', encoding='utf8') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:

        filter_values = [row[i] for i in filter_columns]

        if '1' in filter_values:
            pass

        else:
            orig = row['transcription'].split()
            norm = row['normalized'].split()

            if len(orig) != len(norm):
                c += 1
                print('Mismatch length: {} ||| {}'.format(orig, norm))

if c == 0:
    print('\n\t\033[92mPASSED\033[0m: Dieth transcriptions correspond in length with normalised transcriptions.\n')
else:
    print('\n\t\033[91mFAILED\033[0m: Dieth transcriptions DO NOT correspond in length with normalised transcriptions.\n')
