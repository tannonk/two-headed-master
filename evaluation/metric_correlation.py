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

python3 metric_correlation.py /mnt/tannon/processed/archimob_r1/orig/decode_out/decode /mnt/tannon/case_studies/metric_correlation.csv /mnt/tannon/case_studies/metric_correlation.pdf

"""

import sys
from pathlib import Path
import re
from collections import defaultdict
import pandas as pd

decode_dir = Path(sys.argv[1])
outfile = sys.argv[2]
out_image = sys.argv[3]

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
wip00 = defaultdict(dict)
wip05 = defaultdict(dict)
wip10 = defaultdict(dict)

for group in [wer_files, cer_files, f1_files]:
    for file in group:
        measure, lmwt, wip = file.name.split('_')
        if lmwt in ['1', '2', '3', '4', '5', '6', '7', '8', '9']: # append zero to allow correct lexical sorting
            lmwt = '0'+lmwt
        stat_dict[measure][lmwt+'_'+wip] = extract_stats(str(file))
        if wip == '0.0':
            wip00[measure][lmwt+'_'+wip] = extract_stats(str(file))
        elif wip == '0.5':
            wip05[measure][lmwt+'_'+wip] = extract_stats(str(file))
        elif wip == '1.0':
            wip10[measure][lmwt+'_'+wip] = extract_stats(str(file))

####

df = pd.DataFrame.from_dict(stat_dict)
# df.sort_values(by=df.columns[1], inplace=True)
df.sort_index(axis=0, inplace=True)

df.to_csv(outfile+'.csv', sep=',', header=True, encoding='utf8')

ax = df.plot(stacked=False, colormap='winter', ylim=(0,100), rot=45)
fig = ax.get_figure()
fig.savefig(out_image+'.png', dpi=300, format='png')

####

if wip00:
    df = pd.DataFrame.from_dict(wip00)
    # df.sort_values(by=df.columns[1], inplace=True)
    df.sort_index(axis=0, inplace=True)

    df.to_csv(outfile+'00.csv', sep=',', header=True, encoding='utf8')

    ax = df.plot(stacked=False, colormap='winter', ylim=(0,100), rot=45)
    fig = ax.get_figure()
    fig.savefig(out_image+'00.png', dpi=300, format='png')

if wip05:
    df = pd.DataFrame.from_dict(wip05)
    # df.sort_values(by=df.columns[1], inplace=True)
    df.sort_index(axis=0, inplace=True)

    df.to_csv(outfile+'05.csv', sep=',', header=True, encoding='utf8')

    ax = df.plot(stacked=False, colormap='winter', ylim=(0,100), rot=45)
    fig = ax.get_figure()
    fig.savefig(out_image+'05.png', dpi=300, format='png')

if wip10:
    df = pd.DataFrame.from_dict(wip10)
    # df.sort_values(by=df.columns[1], inplace=True)
    df.sort_index(axis=0, inplace=True)

    df.to_csv(outfile+'10.csv', sep=',', header=True, encoding='utf8')

    ax = df.plot(stacked=False, colormap='winter', ylim=(0,100), rot=45)
    fig = ax.get_figure()
    fig.savefig(out_image+'10.png', dpi=300, format='png')
