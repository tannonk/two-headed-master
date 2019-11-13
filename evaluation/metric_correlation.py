#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Given a directory containing evaluation result files for CER, WER and F1 metrics, this script constructs a csv file of all results.

The output CSV can be analysed to view the correlation of the assessed metrics.

**Note**
    requires python3, pandas
    if running on kaldi instance, first activate conda and then activate the approproitate anconda environment
    e.g.
    conda activate
    source activate py37

Example call:

python3 metric_correlation.py /mnt/tannon/processed/archimob_r1/orig/decode_out/decode /mnt/tannon/case_studies/metric_correlation.csv

"""

import sys
from pathlib import Path
import re
from collections import defaultdict
import pandas as pd

decode_dir = Path(sys.argv[1])
outfile = sys.argv[2]

wer_files = []
cer_files = []
f1_files = []

wer_match = re.compile(r'%WER (\d+\.\d+) \[ ')
f1_match = re.compile(r'\%F1: (\d+\.\d+) %P:')

def extract_stats(file):
    with open(file, 'r', encoding='utf8') as f:
        if 'wer' in file or 'cer' in file:
            score = float(re.search(wer_match, f.read()).group(1))
        elif 'f1' in file:
            score = float(re.search(f1_match, f.read()).group(1))
    return score

if decode_dir.is_dir():
    for file in sorted(decode_dir.iterdir()):
        # print(file.stem)
        if file.stem.startswith('wer'):
            wer_files.append(file)
        elif file.stem.startswith('cer'):
            cer_files.append(file)
        elif file.stem.startswith('f1'):
            f1_files.append(file)
        else:
            pass
else:
    sys.exit(f'Failed to validate {str(decode_dir)}!')

# read in relevant stats from each file
stat_dict = defaultdict(dict)

for group in [wer_files, cer_files, f1_files]:
    for file in group:
        eval, lmwt, wip = file.name.split('_')
        if lmwt in ['7', '8', '9']: # append zero to allow correct lexical sorting
            lmwt = '0'+lmwt
        stat_dict[eval][lmwt+'_'+wip] = extract_stats(str(file))

    # print(f'{extract_stats(i[0])}\t{extract_stats(i[1])}\t{extract_stats(i[2])}')
# print(stat_dict)

df = pd.DataFrame.from_dict(stat_dict)
# df.sort_values(by=df.columns[1], inplace=True)
df.sort_index(axis=0, inplace=True)

df.to_csv(outfile, sep=',', header=True, encoding='utf8')
