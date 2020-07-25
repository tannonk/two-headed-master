#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import json
from collections import Counter

ap = argparse.ArgumentParser()
ap.add_argument("-i", required=True, help="input file")
ap.add_argument("-o", required=True, help="output file")
ap.add_argument("-n", required=False, default=1, type=int, help="threshold")
args = ap.parse_args()

lex = Counter()

with open(args.i, "r", encoding="utf8") as f:
    for line in f:
        line = line.strip().split()
        for w in line:
            lex[w] += 1

with open(args.o, "w", encoding="utf8") as outf:
    for w, c in lex.items():
        if w not in ['<SPOKEN_NOISE>', '<SIL_WORD>', '<NOISE>']:
            if c >= args.n:
                outf.write("{}\n".format(w))


#####################################################


# def mask(utterance, lexicon, n=1):

#     masked_utt = []

#     for w in utterance:
#         if w not in lexicon:
#             masked_utt.append("<unk>")

#         else:
#             masked_utt.append(w)

#     return masked_utt


# read in lexicon
# with open(args.l, "r", encoding="utf8") as lex_file:
#     lex = json.load(lex_file)


# if __name__ == "__main__":

#     lex = count_words(args.i)

#     with open(
#         args.i, "r", encoding="utf8") as inf, open(
#         args.o, "w", encoding="utf8") as outf:

#         for line in inf:
#             masked_line = mask(line.split(), lex)
#             outf.write("{}\n".format(" ".join(masked_line)))

# print("Masking completed.")
