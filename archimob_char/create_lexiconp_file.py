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
lexp = sys.argv[3]

items = []

with open(infile, 'r', encoding='utf8') as inf:
    for line in inf:
        char = line.strip()
        items.append(char)
        # print(char)

        # w, p = line.strip().split()
        # items.append((w, p))

# for item in items:
#     print('{} {}'.format(item[0], item[1]))
#     print('{}@ {}'.format(item[0], item[1]))

with open(lex, 'w', encoding='utf8') as outf1, open(lexp, 'w', encoding='utf8') as outf2:
    outf1.write('{} {}\n'.format('<NOISE>', 'NSN'))
    outf1.write('{} {}\n'.format('<SIL_WORD>', 'SIL'))
    outf1.write('{} {}\n'.format('<SPOKEN_NOISE>', 'SPN'))
    outf2.write('{}\t{}\t{}\n'.format('<NOISE>', '1.0', 'NSN'))
    outf2.write('{}\t{}\t{}\n'.format('<SIL_WORD>', '1.0', 'SIL'))
    outf2.write('{}\t{}\t{}\n'.format('<SPOKEN_NOISE>', '1.0', 'SPN'))
    for char in items:
        # if char in ['<NOISE>', '<SIL_WORD>', '<SPOKEN_NOISE>']:
        #     outf.write('{} {}\n'.format(char, char))
        if char:
            outf1.write('{} {}\n'.format(char, char))
            outf1.write('{}@ {}\n'.format(char, char))
            outf2.write('{}\t{}\t{}\n'.format(char, '1.0', char))
            outf2.write('{}@\t{}\t{}\n'.format(char, '1.0', char))

        # if item[0] in ['<NOISE>', '<SIL_WORD>', '<SPOKEN_NOISE>']:
        #     outf.write('{} {}\n'.format(item[0], item[1]))
        # elif item[0].endswith('@'):
        #     pass
        # else:
        #     outf.write('{} {}\n'.format(item[0], item[1]))
        #     outf.write('{}@ {}\n'.format(item[0], item[1]))

print('Adapted lexicon.')
