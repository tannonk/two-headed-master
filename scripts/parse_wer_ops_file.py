#!/usr/bin/python3
# -*- coding: utf-8 -*-

import json
from collections import defaultdict
import random
import re
import argparse

ap = argparse.ArgumentParser()
ap.add_argument('-o', required=True, help='WER ops file')
ap.add_argument('-m', required=True,
                help='normalised to Dieth mapping (JSON file)')
args = ap.parse_args()

ops_file = args.o
n2d_mapping = args.m

cor_line = re.compile(r'correct\s+.*?(\d+)$')
ins_line = re.compile(r'insertion\s+.*?(\d+)$')
del_line = re.compile(r'deletion\s+.*?(\d+)$')
sub_line = re.compile(r'substitution\s+(\S+)\s+(\S+)\s+(\d+)$')


def get_mappings(n2d_map_file, verbose=0):
    """
    Converts norm2dieth mapping to dieth2norm mapping, which speeds up searches for Dieth transcription word forms produced in decoding.
    """
    d2n_map = defaultdict(set)
    duplicates = 0
    with open(n2d_map_file, 'r', encoding='utf8') as f:
        n2d_map = json.load(f)
        for k, v in n2d_map.items():
            for w in v:
                d2n_map[w].add(k)

    if verbose >= 3:
        print('\nNORM-TO-DIETH mapping sample:')
        sample_keys = random.sample(list(n2d_map), 10)
        for k in sample_keys:
            print('{}\t{}'.format(k, n2d_map[k]))

        print('\nDIETH-TO-NORM mapping sample:')
        sample_keys = random.sample(list(d2n_map), 10)
        for k in sample_keys:
            print('{}\t{}'.format(k, d2n_map[k]))

        multiple_values = sum([1 for v in d2n_map.values() if len(v) > 1])

        print('\nWARNING: {} Dieth transcriptions have multiple corresponding normalised transcriptions.\n'.format(
            multiple_values))

    return n2d_map, d2n_map


def parse_ops(ops_file, n2d, d2n, verbose=0):

    scores = {
        'true_cor': 0,
        'flex_cor': 0,
        'deletions': 0,
        'insertions': 0,
        'substitutions': 0
    }

    with open(ops_file, 'r', encoding='utf8') as inf:
        for line in inf:

            cor = re.match(cor_line, line)
            if cor:
                scores['true_cor'] += int(cor.group(1))
                continue

            deln = re.match(del_line, line)
            if deln:
                scores['deletions'] += int(deln.group(1))
                continue

            ins = re.match(ins_line, line)
            if ins:
                scores['insertions'] += int(ins.group(1))
                continue

            sub = re.match(sub_line, line)
            if sub:
                hyp_word = sub.group(1)
                ref_word = sub.group(2)
                n = int(sub.group(3))
                # print([hyp_word, ref_word, n])

                hyp_norms = d2n[hyp_word]
                ref_norms = d2n[ref_word]

                if hyp_norms.intersection(ref_norms):
                    if verbose >= 2:
                        print('Overlap found: "{}" -- "{}" {}'.format(
                            hyp_word,
                            ref_word,
                            hyp_norms.intersection(ref_norms)))
                    scores['flex_cor'] += n
                else:
                    scores['substitutions'] += n

    if verbose >= 1:
        for k, v in scores.items():
            print(k, ':', '\t', v)
        # print('Correct: {}'.format(true_cor))
        # print('Flex: {}'.format(flex_cor))
        # print('I: {}'.format(insertions))
        # print('D: {}'.format(deletions))
        # print('S: {}'.format(substitutions))

    return scores


def calc_wer(scores):

    total = sum(scores.values())

    wer = (scores['substitutions'] + scores['deletions'] +
           scores['insertions']) / total

    print(wer)


if __name__ == "__main__":

    n2d, d2n = get_mappings(n2d_mapping, verbose=0)

    scores = parse_ops(ops_file, n2d, d2n, verbose=2)

    calc_wer(scores)
