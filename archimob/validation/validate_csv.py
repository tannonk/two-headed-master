#!/usr/bin/python3
# -*- coding: utf-8 -*-

## Author: Tannon Kew
## Email: tannon.kew@uzh.ch

"""
Expects a csv file with the headers (in any order):
    no_relevant_speech, transcription, normalized, missing_audio, anonymity, utt_id, speech_in_speech, audio_id, speaker_id

Example call:
    python3 inspect_csv.py train.csv /mnt/data/archimob_r2/audio
"""

import sys
import csv
from collections import Counter
from pathlib import Path

filter_columns = ['anonymity', 'speech_in_speech', 'missing_audio', 'no_relevant_speech']

csv_file = sys.argv[1]
audio_data = sys.argv[2]

audio_files = set([str(f.stem) for f in Path(audio_data).iterdir() if f.suffix == '.wav'])
spkrs = Counter()
filtered_utterances = 0
c = 0
audio_not_found = 0

with open(csv_file, 'r', encoding='utf8') as f:
    reader = csv.DictReader(f, delimiter=',')

    for row in reader:
        c += 1

        filter_values = [row[i] for i in filter_columns]

        # if one of the 4 cells contains a 1, the utterance is will be filtered, continue on the next row of the file
        if '1' in filter_values:
            filtered_utterances += 1
        else:
            spkrs[row['speaker_id']] += 1
            if row['utt_id'] not in audio_files:
                print("Row on line {} doesn't correspond to chunked wav files\n\t{}".format(c, ','.join(row.values())))
                audio_not_found += 1

print('Valid utterances: {} (out of {} in {})'.format(c-filtered_utterances, c, sys.argv[1]))
print('Filtered utterances: {}'.format(filtered_utterances))
print('Different speakers found in valid utterances: {}'.format(len(spkrs)))
if audio_not_found == 0:
    print('\n\t\033[92mPASSED\033[0m: all audio files exist.\n')
else:
    print('\n\t\033[91mFAILED\033[0m: audio files are missing for {} utterances\n'.format(audio_not_found))
