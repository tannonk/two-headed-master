#!/usr/bin/env python3
# -*- coding: utf8 -*-

import re
import argparse
from pathlib import Path
from lxml import etree, objectify
import normalswiss

meta = re.compile(r"\[\S+?\]")


def get_args():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", required=True, help="input dir of xml files")
    ap.add_argument("-o", required=True, help="output dir of txt files")
    return ap.parse_args()


def clean(line):
    line = re.sub(meta, " ", line)
    return line


if __name__ == "__main__":

    args = get_args()
    parser = etree.XMLParser(remove_blank_text=True)

    with open(args.o, "w", encoding="utf8") as outf:
        for file in sorted(Path(args.i).iterdir()):
            if file.suffix == ".exb":
                # print(file)
                infile = str(file)
                tree = etree.parse(infile, parser)

            for event_tag in tree.getroot().iter("event"):
                clean_utt = clean(event_tag.text)
                clean_utt = normalswiss.normalise(clean_utt)
                if clean_utt:
                    # print(clean_utt)
                    outf.write(clean_utt + "\n")

