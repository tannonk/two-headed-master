#!/usr/bin/env python3
# -*- coding: utf8 -*-
# Tannon Kew

"""

python3
/home/tannon/kaldi_wrk/two-headed-master/evaluation/chars_to_words.py
/mnt/tannon/processed/archimob_r2/char_scratch_2/graph_9gram/eval_out/decode/scoring_kaldi/penalty_0.5/12.txt

python3
/home/tannon/kaldi_wrk/two-headed-master/evaluation/chars_to_words.py
/mnt/tannon/processed/archimob_r2/char_scratch_2/graph_9gram/eval_out/decode/scoring_kaldi/test_filt.txt

"""

import sys
import re

line_pattern = re.compile(r'^(\S+?)(\s|\t)(.*)')

infile = sys.argv[1]
outfile = infile.replace('.txt', '.words.txt')


def compress_words(utt):
    words = []
    cur_word = []
    for char in utt.split():
        if char.endswith('@'):
            cur_word.append(char[:-1])
            words.append(''.join(cur_word))
            cur_word = []
        else:
            cur_word.append(char)

    return ' '.join(words)


with open(infile, 'r', encoding='utf8') as inf, open(outfile, 'w', encoding='utf8') as outf:
    for line in inf:
        m = re.match(line_pattern, line)
        if m:
            id, delim, hyp_chars = m.groups()
            hyp_words = compress_words(hyp_chars)
            outf.write('{}{}{}\n'.format(id, delim, hyp_words))

            # print(id)
            # print(delim, hyp)
