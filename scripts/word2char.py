# !/usr/bin/env python3
# -*- coding: utf8 -*-

import sys

infile = sys.argv[1]
outfile = sys.argv[2]

exclude = set(['<SPOKEN_NOISE>', '<SIL_WORD>', '<NOISE>'])
char_level = []

with open(infile, 'r', encoding='utf8') as inf, open(outfile, 'w', encoding='utf8') as outf:
    for line in inf:
        line = line.split()
        for word in line:
            if word in exclude:
                char_level.append(word)
            else:
                for i, char in enumerate(word):
                    if i == len(word)-1:
                        char_level.append(char+'@')
                    else:
                        char_level.append(char)

        outf.write('{}\n'.format(' '.join(char_level)))
        char_level = []


# """Converts a word-level csv file to character-level"""

# __author__ = "Tannon Kew"

# import argparse
# from pathlib import Path
# import re
# import csv

# def set_args():
#     ap = argparse.ArgumentParser()

#     ap.add_argument('-i', required=True, help='file containing utterances to be split by characters. Expected: one utterance per line file.')

#     ap.add_argument('-o', required=False, help='output file.')

#     ap.add_argument('--col', required=False, default=2, type=int, help='csv column containing original text. Default = 2.')

#     ap.add_argument('--inplace', required=False, action='store_true', default=False, help='if given, the input file is overwritten.')

#     return ap.parse_args()

# def split_chars(infile, outfile, col_num):

#     with open(str(infile), 'r', encoding='utf8') as inf, open(str(outfile), 'w', encoding='utf8') as outf:

#         reader = csv.reader(inf)

#         for line in reader:
#             # print(line)
#             if len(line) > 1:
#                 line = line[col_num]
#             else:
#                 line = line[0]

#             line = line.lower() # lowercase all
#             line = re.sub(r'', ' ', line) # split words to chars
#             line = re.sub(r'\s\s+', ' <w> ', line) # add word boundary character between words
#             line = line.strip()
#             outf.write(line+'\n')

#     print('Words split to characters successfully.')

# def main():

#     args = set_args()

#     infile = Path(args.i)

#     if not args.o:
#         outfile = infile.parent / Path(infile.stem+'_char.txt')
#     else:
#         outfile = args.o

#     col_num = args.col - 1 # account for 0-indexing in python

#     print('Splitting words into characters...')

#     split_chars(infile, outfile, col_num)


# if __name__ == '__main__':
#     main()
