#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Splits audio data into train and test subdirectories

To call:
    python3 archimob/split_audio.py \
    -w chunked wave files \
    --train train.csv \
    --test test.csv \
    --dev dev.csv (if available)

python3 /home/code_base/archimob/split_audio.py -w /home/ubuntu/data/archimob_r2/audio/ --train /home/tannon/processed/exp1/train.csv --test /home/tannon/processed/test.csv

"""

import os
import argparse
import csv
import shutil

def set_args():

    ap = argparse.ArgumentParser()

    ap.add_argument('-w', '--wav_dir', required=True, help='Path to diretory containing all chunked audio files.')

    ap.add_argument('--train', required=True, help='train.csv file')

    ap.add_argument('--test', required=True, help='test.csv file')

    ap.add_argument('--dev', required=False, help='dev.csv file')

    return ap.parse_args()

def split_audio(csv_file, src_dir, trg_dir):
    trg_dir = src_dir+'/'+trg_dir

    if not os.path.exists(trg_dir) and not os.path.isdir(trg_dir):
        os.makedirs(trg_dir)

    not_found = 0
    moved = 0

    with open(csv_file, 'r', encoding='utf8') as inf:
        reader = csv.DictReader(inf, delimiter=',')
        for row in reader:
            src_file = src_dir+'/'+row['utt_id']+'.wav'
            trg_file = trg_dir+'/'+row['utt_id']+'.wav'
            try:
                shutil.move(src_file, trg_file)
                moved += 1
            except FileNotFoundError:
                not_found += 1

    print('{} audio files moved to {}'.format(moved, trg_dir))
    print('{} audio files not found in {}'.format(not_found, src_dir))

def main():
    args = set_args()

    if args.train:
        split_audio(args.train, args.wav_dir, 'train')
    if args.test:
        split_audio(args.test, args.wav_dir, 'test')
    if args.dev:
        split_audio(args.dev, args.wav_dir, 'dev')


if __name__ == '__main__':
    main()
