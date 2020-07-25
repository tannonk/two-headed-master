#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
python3 calculate_av_utt_lengths.py -i train

"""


import argparse


def set_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i', nargs='*', help='input file(s)')
    return ap.parse_args()


def av_length(files):

    c = 0
    tokens = 0

    for file in files:
        with open(file, 'r', encoding='utf8') as f:
            for line in f:
                c += 1
                tokens += len(line.strip().split())

    print('lines counted: {}'.format(c))
    print('tokens counted: {}'.format(tokens))
    print('average tokens per line: {:.2f}'.format((tokens/c)))


if __name__ == "__main__":
    args = set_args()

    av_length(args.i)
