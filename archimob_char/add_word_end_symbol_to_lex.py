#!/usr/bin/python3
#! -*- coding: utf-8 -*-

"""
<NOISE> NSN
<SIL_WORD> SIL
<SPOKEN_NOISE> SPN
a a
ai ai
au au
á á

-->

<NOISE> NSN
<SIL_WORD> SIL
<SPOKEN_NOISE> SPN
a a
a@ a

ai ai
ai@ ai
"""

import sys
import re
import argparse
import unicodedata
import json
from collections import Counter

infile = sys.argv[1]
lex = sys.argv[2]
# lexp = sys.argv[3]

items = []

with open(infile, 'r', encoding='utf8') as inf:
    for line in inf:
        char = line.strip()
        items.append(char)

with open(lex, 'w', encoding='utf8') as outf1:
    outf1.write('{} {}\n'.format('<NOISE>', 'NSN'))
    outf1.write('{} {}\n'.format('<SIL_WORD>', 'SIL'))
    outf1.write('{} {}\n'.format('<SPOKEN_NOISE>', 'SPN'))
    for char in items:
        if char:
            outf1.write('{} {}\n'.format(char, char))
            outf1.write('{}@ {}\n'.format(char, char))

print('Adapted lexicon.')
