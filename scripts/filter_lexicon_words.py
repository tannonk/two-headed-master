#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import csv
import re
from collections import Counter, defaultdict

"""

Filters words from a lexicon file if they do not appear in
the provided corpus file.

Purpose: to ensure that lexicon only contains words from
training set.

"""

args = argparse.ArgumentParser()
args.add_argument('-c', '--corpus', required=True, help='Corpus CSV file')
args.add_argument('-l', '--lexicon', required=True, help='lexicon file')
args.add_argument('-t', '--trans', required=True, help='translation type')
args.add_argument('-o', '--outfile', required=False, help='output file')
args = args.parse_args()


print('Collecting Vocabulary...')

corpus_vocab = Counter()
with open(args.corpus, 'r', encoding='utf8') as corpus_f:
    reader = csv.DictReader(corpus_f)
    for row in reader:
        tokens = row[args.trans].split()
        corpus_vocab.update(tokens)

# print(corpus_vocab.most_common(10))

print('Collecting Lexicon...')

lex = defaultdict(set)

with open(args.lexicon, 'r', encoding='utf8') as f:
    for line in f:
        line = re.split(r'[\s\t]', line.strip())
        lex[line[0]].add(' '.join(line[1:]))

# print(lex)

if args.outfile:
    with open(args.outfile, 'w', encoding='utf8') as f:
        for k in sorted(lex.keys()):
            if k in corpus_vocab:
                for pron in lex[k]:
                    f.write('{} {}\n'.format(k, pron))
else:
    for k in sorted(lex.keys()):
        if k in corpus_vocab:
            for pron in lex[k]:
                f.write('{} {}\n'.format(k, pron))
