#!/usr/bin/python3
# -*- coding: utf-8 -*-

# import codecs
import unicodedata
import re
import sys
import csv

# file = "/Users/tannon/switchdrive/MA/tannon/data/asr_data/archimob_r2.csv"
# file = "/Users/tannon/switchdrive/MA/tannon/working_scripts/diacritic_examples.txt"

infile = sys.argv[1]
outfile = sys.argv[2]


def normalise_chars(utt, map_diacritic=None):
    """
    removes unnecessary/inconsistent diacritics from graphemes 
    """

    # NOTE: unicodedata.normalize
    # does NOT cover all examples in the data, so we have to
    # do this manually.  The compound diacritics always follow
    # the letter they combine with.

    chars = [char for char in ''.join(utt)]

    chars.reverse()
    chunk = []
    tmp_chars = []

    for char in chars:
        char_name = unicodedata.name(char)

        if unicodedata.combining(char):
            # print(char)
            char_name = None

        elif 'WITH DIAERESIS AND GRAVE' in char_name:
            # ǜ --> ü
            char_name = char_name[:-10]
            tmp_chars.append(unicodedata.lookup(char_name))

        elif re.search('WITH (ACUTE|GRAVE|TILDE)', char_name):
            # removes all ˜, ´, `
            char_name = char_name[:-11]

        if char_name:
            tmp_chars.append(unicodedata.lookup(char_name))

    chars = [char for char in tmp_chars]
    chars.reverse()

    return ''.join(chars)


if infile.endswith('.csv'):
    with open(infile, 'r', encoding='utf8') as inf, open(outfile, 'w', encoding='utf8') as outf:
        reader = csv.DictReader(inf)
        writer = csv.DictWriter(outf, fieldnames=[
            'utt_id', 'transcription', 'normalized', 'speaker_id', 'audio_id', 'anonymity', 'speech_in_speech', 'missing_audio', 'no_relevant_speech'
        ])

        writer.writeheader()

        for line in reader:
            line['transcription'] = normalise_chars(line['transcription'])
            # print(line)
            writer.writerow(line)

else:
    with open(infile, 'r', encoding='utf8') as inf, open(outfile, 'w', encoding='utf8') as outf:
        for line in f:
            line = normalise_chars(line.strip())
            outf.write('{}\n'.format(line))
