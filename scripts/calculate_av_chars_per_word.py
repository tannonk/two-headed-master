#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys

# counts = []
char_counts = []

for file in sys.argv[1:]:
    with open(file, 'r', encoding='utf8') as f:
        for line in f:
            line = line.strip().split()
            n = 0  # initialise n
            for char in line:
                if char.endswith('@'):
                    n += 1
                    char_counts.append(n)
                    n = 0  # reset current n
                else:
                    n += 1


def calc_av(l):
    return sum(l) / len(l)


print(calc_av(char_counts))
