#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import argparse
import csv
from pathlib import Path

bad_chars = {
    'á': 'a',  # árosa, gáelte
    'è': 'e',  # hèe, èhe
    'é': 'e',  # weitgeéend, éer, schésse
    'ì': 'i',  # drììschrììchen, drììschrììche
    '*': '*',  # p***, m*** (anon)
    'ĩ': 'i',  # pĩscha
    'à': 'a',  # voilà, vis-à-vis
    'ẽ': 'e',  # schulẽẽ, ẽẽgagiert
    'ò': 'o',  # òu, hejò
    "'": '',  # d'amato, 'tschuldigung
    'õ': 'o',  # lijõõ, sõõdo
}


def get_args():
    args = argparse.ArgumentParser()
    args.add_argument('-i', required=True, help='infile for normalisation')
    args.add_argument('--corpus', action='store_true', required=False,
                      help='either vocab or tokenised corpus file')
    args.add_argument('-o', required=False, default=None,
                      help='name/path of output file')
    return args.parse_args()


def norm_vocab(file, outfile=None):
    """
    Normalises all words in a vocab file i.e. file
    containing one WORD per line.
    """
    with open(file, 'r', encoding='utf8') as f:
        with open(outfile, 'w', encoding='utf8') as outf:
            for line in f:
                word = line.strip()
                norm_word = []
                for char in word:
                    if char not in bad_chars:
                        norm_word.append(char)
                    else:
                        norm_word.append(bad_chars[char])
                outf.write('{}\n'.format(''.join(norm_word)))


def norm_corpus(file, outfile):
    """
    Normalises all words in a corpus file i.e. one SENTENCE
    per line.
    """

    with open(file, 'r', encoding='utf8') as f:
        with open(outfile, 'w', encoding='utf8') as outf:
            for line in f:
                norm_sent = []
                words = line.strip().split()
                for word in words:
                    norm_word = []
                    for char in word:
                        if char not in bad_chars:
                            norm_word.append(char)
                        else:
                            norm_word.append(bad_chars[char])
                    norm_sent.append(''.join(norm_word))
                outf.write('{}\n'.format(' '.join(norm_sent)))


def norm_csv(infile, outfile):
    """
    Normalises all words in a corpus file i.e. one SENTENCE
    per line.
    """

    if not outfile:
        f_dir = Path(infile).parent
        print(f_dir)
        f_name = 'normalised_{}.csv'.format(Path(infile).stem)
        outfile = f_dir.joinpath(f_name)
        print(outfile)

    with open(infile, 'r', encoding='utf8') as inf:
        with open(str(outfile), 'w', encoding='utf8') as outf:
            i_f = csv.DictReader(inf)
            o_f = csv.DictWriter(outf, i_f.fieldnames)

            # print(i_f.fieldnames)
            o_f.writeheader()

            for line in i_f:
                # print(line)
                norm_sent = []
                words = line['normalized'].strip().split()
                for word in words:
                    norm_word = []
                    for char in word:
                        if char not in bad_chars:
                            norm_word.append(char)
                        else:
                            norm_word.append(bad_chars[char])
                    norm_sent.append(''.join(norm_word))
                line['normalized'] = ' '.join(norm_sent)
                o_f.writerow(line)


if __name__ == "__main__":

    args = get_args()

    if args.i.endswith('.csv'):
        norm_csv(args.i, args.o)
    elif args.corpus:
        norm_corpus(args.i, args.o)
    else:
        norm_vocab(args.i, args.o)
