# !/usr/bin/env python3
# -*- coding: utf8 -*-


import sys
from collections import defaultdict

# lexicon = defaultdict(str)
lexicon = set()

with open(sys.argv[1], 'r', encoding='utf8') as inf:
    with open(sys.argv[2], 'w', encoding='utf8') as outf:
        for line in inf:
            words = []
            line = line.strip().split()
            word = []
            for char in line:
                if char == '@':
                    if '*' in word:
                        pass
                    elif word:
                        words.append(''.join(word))
                        # add word to lexicon
                        # lexicon[''.join(word)] = '
                        # '.join(word)
                        # lexicon.add(''.join(word))
                        word = []
                    else:
                        pass
                else:
                    word.append(char)
            if words:
                outf.write('{}\n'.format(' '.join(words)))


# with open(sys.argv[3], 'w', encoding='utf8') as lexf:
#     for i in lexicon:
#         lexf.write('{}\n'.format(i))
# #     for k, v in lexicon.items():
#         if k and not '*' in k:
#             lexf.write('{} {}\n'.format(k, v))


# with open(sys.argv[1], 'r', encoding='utf8') as inf:
#     with open(sys.argv[2], 'w', encoding='utf8') as outf:
#         for line in inf:
#             words = []
#             line = line.strip().split()
#             word = []
#             for char in line:
#                 if char.endswith('@'):
#                     word.append(char[:-1])
#                     words.append(''.join(word))
#                     word = []
#                 else:
#                     word.append(char)
#             if words:
#                 outf.write('{}\n'.format(' '.join(words)))
