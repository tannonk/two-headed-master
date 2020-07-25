#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys

"c o n s u m e r s _ m a y _ w a n t _ t o _ m o v e _ t h e i r _ t e l e p h o n e s _ a _ l i t t l e _ c l o s e r _ t o _ t h e _ t v _ s e t < u n k > _ < u n k > _ w a t c h i"

# counts = []
char_counts = []

for file in sys.argv[1:]:
    with open(file, 'r', encoding='utf8') as f:
        for line in f:
            line = line.strip().split()
            n = 0  # initialise n
            for char in line:

                if char == '@':  # for ArchiMob
                    # if char == '_': # for PTB
                    char_counts.append(n)
                    n = 0  # reset current n
                else:
                    n += 1


def calc_av(l):
    return sum(l) / len(l)


print(calc_av(char_counts))
