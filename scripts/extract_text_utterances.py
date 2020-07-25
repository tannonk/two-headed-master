#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Reads in an ArchiMob csv file and outputs the corresponding
text transcriptions

python3 /home/tannon/my_scripts/extract_text_utterances.py
-i /mnt/tannon/corpus_data/csv_files/archimob_r2/dev.csv -c
transcription -o dev_orig_utt.txt



"""

import sys
import csv
import argparse
import re
# from pathlib import Path
# from collections import Counter, defaultdict

ap = argparse.ArgumentParser()
ap.add_argument('-c', '--corpus', help='corpus file')
ap.add_argument('--trans', help='transcription type')
ap.add_argument('-o', '--outfile', help='outfile')
args = ap.parse_args()


def clean_utt(utt):
    utt = re.sub(r'\s?<SIL_WORD>\s?', ' ', utt)
    utt = re.sub(r'\s?<SPOKEN_NOISE>\s?', ' ', utt)
    utt = re.sub(r'\s?<NOISE>\s?', ' ', utt)
    return utt.strip()


with open(args.corpus, 'r', encoding='utf8') as inf:
    with open(args.outfile, 'w', encoding='utf8') as outf:
        r = csv.DictReader(inf)
        for row in r:
            utt = clean_utt(row[args.trans])
            if utt:
                outf.write("{}\n".format(utt))
