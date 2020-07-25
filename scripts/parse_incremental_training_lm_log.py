#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import re
from collections import OrderedDict
# import pandas as pd
# from matplotlib import pyplot as plt
import math

infile = sys.argv[1]

new_split = re.compile(r"Loading corpus\s+.*?/splits/train_(\d+)")
ppl = re.compile(r"./test.txt\s+(\d+\.\d+)")

scores = {}

with open(infile, 'r', encoding='utf8') as inf:

    current_split = 0
    current_score = 0

    for line in inf:

        splt = re.search(new_split, line)
        if splt:
            current_split = int(splt.group(1))
            continue

        scr = re.search(ppl, line)
        if scr:
            current_score = (scr.group(1))
            scores[current_split] = math.ceil(float(current_score))

            current_split = 0
            current_score = 0

for k in sorted(scores.keys()):
    print('{},{}'.format(k, scores[k]))

# idx = [i for i in range(len(scores))]
# print(idx)
# df = pd.DataFrame.from_dict(scores, orient='index')
# , orient='index',
# columns=('split_n', 'ppl'))

# print(df)
