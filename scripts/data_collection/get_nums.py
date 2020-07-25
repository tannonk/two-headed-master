#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
extract normalised numbers
"""

import sys
from pathlib import Path
from collections import defaultdict

indir = Path(sys.argv[1])

nums = {
    'ein': set(),
    'eine': set(),
    'zwei': set(),
    'drei': set(),
    'vier': set(),
    'fünf': set(),
    'sechs': set(),
    'sieben': set(),
    'acht': set(),
    'nein': set(),
    'zehn': set(),
    }

files = [f for f in indir.iterdir() if f.suffix == '.tsv']

for f in files:
    with open(f, 'r', encoding='utf8') as inf:
        for line in inf:
            try:
                # iri     ihre    PPOSAT  d1007-u2-w1
                w, norm, pos, id = line.strip().split('\t')
                if norm in nums.keys():
                    nums[norm].add(w)

            except ValueError:
                pass

print(nums)
