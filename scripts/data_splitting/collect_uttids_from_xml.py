#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
This script reads in meta data for utterances from a collection of archimob xml files and writes them out to a JSON file.

Example call:

    python3 collect_uttids_from_xml.py \

    -i /Users/tannon/switchdrive/MA/pos-tagging_testsets/test_* \
    -o test_utterances.json \
    --dialect-map /Users/tannon/switchdrive/MA/tannon/data/spkr_dialect.json
"""

from pathlib import Path
from lxml import etree
import json
import argparse

def set_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i', required=True, nargs='*', help='set of xml files')
    ap.add_argument('-o', required=True, help='name of JSON output file')
    ap.add_argument('--dialect-map', required=False, help='path to spkr_dialect_mapping (JSON file)')
    return ap.parse_args()

def read_in_json(json_file):
    with open(json_file, 'r') as f:
        d = json.load(f)
    return d

def collect_utt_meta_data(files, spk_dialect_map):

    xml_ns = 'http://www.w3.org/XML/1998/namespace'
    d = {'utterances': []}
    c = 0 # utterance counter

    for f in files:
        tree = etree.parse(str(f))
        ns = tree.getroot().nsmap[None]

        for u in tree.getroot().iter('{'+ns+'}u'):
            c += 1
            start = u.attrib['start'].replace('media_pointers#', '')
            id = u.attrib['{'+xml_ns+'}id']
            spkr = u.attrib['who'].replace('person_db#', '')
            dialect = spk_dialect_map.get(spkr, 'UNK')

            # print(id, start, spkr)
            entry = {
                'utt_id': id,
                'start': start,
                'speaker': spkr,
                'dialect': dialect
                }

            d['utterances'].append(entry)

    print(c, 'utterances added')

    return d

def main():
    args = set_args()

    spkr_dialects = read_in_json(args.dialect_map)

    d = collect_utt_meta_data(args.i, spkr_dialects)

    if d['utterances']:
        with open(args.o, 'w', encoding='utf8') as outf:
            json.dump(d, outf, indent=4)

    else:
        print('WARNING: no utterances found.')


if __name__ == '__main__':
    main()
