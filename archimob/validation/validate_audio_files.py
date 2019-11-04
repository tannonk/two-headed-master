#!/usr/bin/python3
# -*- coding: utf-8 -*-

## Author: Tannon Kew
## Email: tannon.kew@uzh.ch

"""
Validates whether audio files are non-empty.

Example call:

    python3 validate_audio_files.py /mnt/data/archimob_r2/audio
"""

import sys
import csv
from pathlib import Path

audio_data = sys.argv[1]

no_audio = 0

for f in Path(audio_data).iterdir():
    if f.suffix == '.wav':
        if f.stat().st_size == 0:
            no_audio += 1

if no_audio == 0:
    print('\n\t\033[92mPASSED\033[0m: audio files in {} are non-empty.\n'.format(audio_data))
else:
    print('\n\t\033[91mFAIL\033[0m: {} audio files in {} are empty.\n'.format(no_audio, audio_data))

# audio_files = set([str(f.stem) for f in audio_data.iterdir() if f.suffix == '.wav'])

# not_found = 0
#
# filter_columns = ['anonymity', 'speech_in_speech', 'missing_audio', 'no_relevant_speech']
#
# with open(csv_file,'r',encoding='utf8') as f:
#     reader = csv.DictReader(f, delimiter=',')
#     for row in reader:
#
#         filter_values = [row[i] for i in filter_columns]
#
#         if '1' in filter_values:
#             pass
#         elif row['utt_id'] not in audio_files:
#             # print('{} not found in audio data.'.format(row['utt_id']))
#             not_found += 1
#
# print('{} items not found in audio data.'.format(not_found))
