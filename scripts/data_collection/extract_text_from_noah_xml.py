#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Extract sentences from NOAH xml corpus files and writes sentences to a corresponding txt file.

Example call:
    python3 ~/switchdrive/MA/tannon/working_scripts/NOAH_extract_sentences.py ~/switchdrive/MA/tannon/data/NOAH-Corpus-master > ~/switchdrive/MA/tannon/data/NOAH_sentences/
"""

import sys
from pathlib import Path
from lxml import etree

punct = """!"#$%&'()*+,-–./:;<=>?@[\]^_`{|}~«‹›»’‘“”„…•"""

indir = Path(sys.argv[1])
outdir = Path(sys.argv[2])
files = [f for f in indir.iterdir() if f.suffix == '.xml']

for f in files:

    outfile = outdir / Path(f.stem+'.txt')

    with open(outfile, 'w', encoding='utf8') as outf:
        context = etree.iterparse(str(f), tag='s')
        for _, elem in context:
            sent = []
            for w in elem.findall('./w'):
                token = w.text
                if token not in punct:
                    sent.append(token.strip(punct).lower())

            if sent != []:
                outf.write('{}\n'.format(' '.join(sent)))
