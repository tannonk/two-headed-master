#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""

client_id	path	sentence	up_votes	down_votes	age	gender	accent
114	21435.flac	in keiner dieser debatten wurden diese grundsätze irgendwie bestritten oder angezweifelt.	-	-	-	-	-

to 'archimob style csv' format:

utt_id,transcription,normalized,speaker_id,audio_id,anonymity,speech_in_speech,missing_audio,no_relevant_speech
114-21435.flac,in keiner dieser debatten wurden diese grundsätze irgendwie bestritten oder angezweifelt .,,114,21435.flac,0,0,0,0


"""

import sys
import csv
from nltk.tokenize import toktok

tok = toktok.ToktokTokenizer()
# de_tok = nltk.data.load(resource_url='tokenizers/punkt/german.pickle')
# print(type(de_tok))
# print(type(tok))
swisstext_file = sys.argv[1]
outfile = sys.argv[2]

archimob_fieldnames = ['utt_id', 'transcription', 'normalized', 'speaker_id', 'audio_id',
                       'anonymity', 'speech_in_speech', 'missing_audio', 'no_relevant_speech']

swisstext_fieldnames = ['client_id', 'path', 'sentence',
                        'up_votes', 'down_votes', 'age', 'gender', 'accent']

with open(outfile, 'w', encoding='utf8') as outf:

    writer = csv.writer(outf, delimiter=',')
    writer.writerow(archimob_fieldnames)

    with open(swisstext_file, 'r', encoding='utf8') as inf:
        reader = csv.DictReader(inf, delimiter='\t')
        for row in reader:
            utt_id = row['client_id']+'-'+row['path']
            transcription = tok.tokenize(row['sentence'], return_str=True)
            normalized = transcription
            speaker_id = row['client_id']
            audio_id = row['path']
            anonymity = '0'
            speech_in_speech = '0'
            missing_audio = '0'
            no_relevant_speech = '0'

            writer.writerow([utt_id, transcription, normalized, speaker_id, audio_id,
                             anonymity, speech_in_speech, missing_audio, no_relevant_speech])
