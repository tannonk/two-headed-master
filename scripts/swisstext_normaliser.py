#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import re

infile = sys.argv[1]
# outfile = sys.argv[2]

ALLOWED_CHARS = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'ä', 'ö', 'ü',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ' ',
    ',', ';', ':', '.', '?', '!',
}
WHITESPACE_REGEX = re.compile(r'[ \t]+')


def preprocess_transcript_for_corpus(transcript):
    transcript = transcript.lower()
    transcript = transcript.replace('á', 'a')
    transcript = transcript.replace('à', 'a')
    transcript = transcript.replace('â', 'a')
    transcript = transcript.replace('ç', 'c')
    transcript = transcript.replace('é', 'e')
    transcript = transcript.replace('è', 'e')
    transcript = transcript.replace('ê', 'e')
    transcript = transcript.replace('í', 'i')
    transcript = transcript.replace('ì', 'i')
    transcript = transcript.replace('î', 'i')
    transcript = transcript.replace('ñ', 'n')
    transcript = transcript.replace('ó', 'o')
    transcript = transcript.replace('ò', 'o')
    transcript = transcript.replace('ô', 'o')
    transcript = transcript.replace('ú', 'u')
    transcript = transcript.replace('ù', 'u')
    transcript = transcript.replace('û', 'u')
    transcript = transcript.replace('ș', 's')
    transcript = transcript.replace('ş', 's')
    transcript = transcript.replace('ß', 'ss')
    transcript = transcript.replace('-', ' ')
    # Not used consistently, better to replace with space as well
    transcript = transcript.replace('–', ' ')
    transcript = transcript.replace('/', ' ')
    transcript = WHITESPACE_REGEX.sub(' ', transcript)
    transcript = ''.join(
        [char for char in transcript if char in ALLOWED_CHARS])
    transcript = WHITESPACE_REGEX.sub(' ', transcript)
    transcript = transcript.strip()

    return transcript


with open(infile, 'r', encoding='utf8') as f:
    for line in f:
        line = preprocess_transcript_for_corpus(line.strip())
        print(line)
