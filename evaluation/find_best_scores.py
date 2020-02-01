#!/usr/bin/env python3
# -*- coding: utf8 -*-
# Tannon Kew

"""
Example call:

python3
/home/tannon/kaldi_wrk/two-headed-master/evaluation/find_best_flexwer.py
.../orig/baseline/lw_out/decod

"""

import sys
from pathlib import Path
import re
from collections import defaultdict

flexwer_content = re.compile(r'%FLEXWER (\d+\.?\d+) (\[.*\])')
f1_content = re.compile(r'%F1: (\d+\.?\d+)')
decode_dir = sys.argv[1]
flexwer_outfile = Path(sys.argv[1]) / Path('scoring_kaldi/best_flexwer')
f1_outfile = Path(sys.argv[1]) / Path('scoring_kaldi/best_f1')


def extract_score_from_flexwer(file):
    """
    %FLEXWER 47.13 [7322 / 15537, 3041 ins, 310 del, 3971 sub] /mnt/tannon/processed/archimob_r2/orig/baseline/lw_out/decode/scoring_kaldi/penalty_0.0/1.txt
    """

    with open(str(file), 'r', encoding='utf8') as f:
        info = f.read()
        m = re.match(flexwer_content, info)
        if m:
            return (float(m.group(1)), m.group(2))


def extract_score_from_flexf1(file):
    """
    %F1: 66.07 %P: 69.93 %R: 64.74 [ %Flex: 22.40 1258 / 5616 ]
    """
    with open(str(file), 'r', encoding='utf8') as f:
        info = f.read()
        # print(info)
        m = re.match(f1_content, info)
        if m:
            return (float(m.group(1)), info.strip())


wer_scores = defaultdict(float)
f1_scores = defaultdict(float)

for f in sorted(Path(decode_dir).iterdir()):
    if f.name.startswith('flexwer_'):
        # print(f)
        # info, s =
        wer_scores[str(f)] = extract_score_from_flexwer(f)
    elif f.name.startswith('f1_'):
        f1_scores[str(f)] = extract_score_from_flexf1(f)

# get best 1 score from flexwer
if len(wer_scores) > 1:
    best_wer = list(sorted(wer_scores.items(), key=lambda x: x[1][0]))[0]
    # print(best_score[1][0], best_score[1][1], best_score[0])
    with open(str(flexwer_outfile), 'w', encoding='utf8') as outf:
        outf.write('%FLEXWER {} {} {}\n'.format(
            best_wer[1][0], best_wer[1][1], best_wer[0]))

if len(f1_scores) > 1:
    # get best 1 score from flexwer
    # print(f1_scores)
    best_f1 = list(sorted(f1_scores.items(),
                          key=lambda x: x[1][0], reverse=True))[0]

    # print(best_f1)
    with open(str(f1_outfile), 'w', encoding='utf8') as outf:
        outf.write('{} {}\n'.format(best_f1[1][1], best_f1[0]))
