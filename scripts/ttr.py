#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import csv
from collections import Counter

file = sys.argv[1]
if len(sys.argv) == 3:
    trans = sys.argv[2]

vocab_count = Counter()

if file.endswith(".csv"):
    with open(file, "r", encoding="utf8") as f:
        reader = csv.DictReader(f, delimiter=",")
        for row in reader:
            for w in row[trans].split():
                vocab_count[w] += 1
else:
    with open(file, "r", encoding="utf8") as f:
        for line in f:
            for w in line.split():
                vocab_count[w] += 1


def ttr(d):
    toks = sum(d.values())
    print("tokens:", toks)
    types = len(d.keys())
    print("types:", types)

    return (types / toks) * 100


print(ttr(vocab_count))
