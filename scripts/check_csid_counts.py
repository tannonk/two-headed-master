#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys

infile = sys.argv[1]

t_c = 0
t_s = 0
t_i = 0
t_d = 0

with open(infile, 'r', encoding='utf8') as inf:
    for line in inf:
        if '#csid' in line:
            line_list = line.strip().split()
            c, s, i, d = [int(x) for x in line_list[-4:]]
            t_c += c
            t_s += s
            t_i += i
            t_d += d

print('#csid:', t_c, t_s, t_i, t_d)


# csid: 5353 4548 432 1165
