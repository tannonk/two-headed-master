#!/usr/bin/python3
#! -*- coding: utf-8 -*-

import csv
import json
import sys
from collections import defaultdict

infile = sys.argv[1]
outfile = sys.argv[2]

exclude = set(['<SPOKEN_NOISE>', '<SIL_WORD>', '<NOISE>'])

mapping = defaultdict(set)

with open(infile, 'r', encoding='utf8') as f:
    reader = csv.DictReader(f)
    for line in reader:
        dieth = line['transcription'].split()
        norm = line['normalized'].split()

        if len(dieth) != len(norm):
            raise(IndexError, "Number of tokens do not match!")

        for i in range(len(norm)):
            if norm[i] not in exclude:
                mapping[norm[i]].add(dieth[i])


# convert set to list to write out as JSON
json_compatible_dict = {}
for k, v in mapping.items():
    json_compatible_dict[k] = sorted(list(v))  # sort for consistency

with open(outfile, 'w', encoding='utf8') as outf:
    json.dump(json_compatible_dict, outf, indent=4,
              ensure_ascii=False, sort_keys=True)

print('Finished creating mapping!')
