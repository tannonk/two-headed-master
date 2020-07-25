#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Parses output.log from basic_lm_comparisons.sh and collects each model and its ppl score on the testset.

Example call:
    python3 /home/tannon/my_scripts/process_lm_stats.py output.log
"""

import sys
import re
import math
from collections import defaultdict

mitlm_build = re.compile(r'\d+?\.\d+\s+?Saving LM to')
mitlm_eval = re.compile(r'\d+?\.\d+\s+?/')
# srilm_build = re.compile(r'\+ ngram-count\s')
srilm_eval = re.compile(r'\+ ngram\s')
srilm_result = re.compile(r'\d+? zeroprobs')

models = {}

with open(sys.argv[1], 'r', encoding='utf8') as f:

    current_model = ''
    current_model_ppl = ''

    for line in f:
        line = line.strip()

        if re.match(mitlm_build, line):
            model_name = line.split('/')[-1].strip('...')
            current_model = model_name
        elif re.match(mitlm_eval, line):
            current_model_ppl = float(line.split()[-1].strip())
            # add results to dict and reset vars
            models[current_model] = current_model_ppl
            current_model = ''
            current_model_ppl = ''
        elif re.match(srilm_eval, line):
            m = re.search(r'-lm (\S+)', line)
            if m:
                current_model = m.group(1).split('/')[-1]
        elif re.match(srilm_result, line):
            m = re.search(r'ppl= (\S+) ppl1', line)
            if m:
                current_model_ppl = float(m.group(1))
                models[current_model] = current_model_ppl
                current_model = ''
                current_model_ppl = ''


# for key, value in sorted(models.items(), key=lambda x: x[0]):
#     print("{}\t{}".format(key, value))
# for k, v in models.items():
#     print(k, '\t', v)

# reformat

# out_data = defaultdict(list)

for m, _ in sorted(models.items(), key=lambda x: x[0]):
    n = int(re.search(r'(\d)', m).group(1))
    if n and n < 7:
        model_name = re.sub('_', ' ', m)
        model_name = re.sub(r'\d', ' ', model_name)
        model_name = re.sub('.arpa', '', model_name)
        model_name = re.sub('open', 'O', model_name)
        model_name = re.sub('tuned', 'T', model_name)
        model_name = re.sub('int', '*', model_name)
        model_name = re.sub(r'\s+', ' ', model_name)
        model_name = model_name.strip().upper()
        # model_name = re.sub('tuned', 'T', model_name)

        score = math.ceil(models[m])
        # out_data[n].append((model_name.upper(), score))
        print("{},{},{}".format(n, model_name, score))

# print(out_data)
