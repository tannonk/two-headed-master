#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import sys
import json

infile = sys.argv[1]
outfile = sys.argv[2]
speaker_mapping = sys.argv[3]

def read_in_json(json_file):
    with open(json_file, 'r') as f:
        d = json.load(f)
    return d

spkr_dialects = read_in_json(speaker_mapping)

with open(infile, 'r', encoding='utf8') as inf:

    d = {'utterances': []}

    reader = csv.DictReader(inf, delimiter=',')
    for row in reader:

        entry = {
            'utt_id': row['utt_id'],
            'start': row['audio_id'],
            'speaker': row['speaker_id'],
            'dialect': spkr_dialects.get(row['speaker_id'], 'UNK')
            }

        d['utterances'].append(entry)

    if d['utterances']:
        with open(outfile, 'w', encoding='utf8') as outf:
            json.dump(d, outf, indent=4)
