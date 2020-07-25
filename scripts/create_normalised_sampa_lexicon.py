#!/usr/bin/python3
#! -*- coding: utf-8 -*-

"""
This program creates a simple lexicon with a one to one grapheme to phoneme
mapping, besides some consonant clusters that are known to map to a single
phone.

Example call:
    python3 create_sampa_normalised_lexicon.py -s SAMPA/*_small.csv -v normalised_vocabulary.txt -o normalised_lexicon.txt

"""

import sys
import re
import argparse
from collections import defaultdict, Counter
from pathlib import Path
import random


def get_args():
    """
    Returns the command line arguments
    """

    my_desc = "Generates pronunciations for an input vocabulary based on SAMPA data provided by URPP and Swisscom"

    parser = argparse.ArgumentParser(description=my_desc)

    parser.add_argument("--vocabulary", "-v", required=False,
                        help="Input vocabulary")

    parser.add_argument(
        "--sampa-files",
        "-s",
        nargs="*",
        required=True,
        help="File containing dictionary of gsw words and SAMPA pronunciations",
    )

    parser.add_argument(
        "--col_n",
        required=False,
        type=int,
        default=0,
        help="if given, selects only the nth column for phonemic transcription.",
    )

    parser.add_argument(
        "--random",
        "-rand",
        action="store_true",
        required=False,
        help="If given, a random pronunciation is selected from the avaliable SAMPA transcriptions",
    )

    parser.add_argument("--outfile", "-o",
                        help="Output lexicon", required=True)

    args = parser.parse_args()

    return args


def normalise_pron(s):
    s = s.strip().replace('_', ' ')
    s = re.sub(r'\s+', ' ', s)
    return s


def normalise_word(s):
    s = re.sub(r'_LXA', '', s)
    s = re.sub(r'_MRA', '', s)
    s = s.strip().replace(' ', '_').lower()
    return s


def swiss_text_norm(transcript):
    ALLOWED_CHARS = {
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        'ä', 'ö', 'ü',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        ' ',
        ',', ';', ':', '.', '?', '!',
    }

    WHITESPACE_REGEX = re.compile(r'[ \t]+')

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


def read_sampa_dict(sampa_files, col_num=0, rand=False):
    """
    Reads all SAMPA files provided to create a dictionary
    with a gsw word as a key and the set of all possible
    pronunciations as a value for that key.

    sampa_files: list of SAMPA annotated files
    col_num (int): number of column to take
    """

    pron_dict = defaultdict(set)

    for file in sampa_files:
        with open(file, "r", encoding="utf8") as f:
            for line in f:
                line = line.rstrip("\n").split("\t")
                word = line[0]
                # normalise word

                word = normalise_word(word)
                word = swiss_text_norm(word)

                if col_num:
                    prons = [line[col_num - 1]]
                    # print(prons)
                else:
                    prons = set(line[1:7])

                    if rand:
                        prons = [random.choice(list(prons))]

                # print(word, len(prons), list(prons))
                for pron in prons:
                    pron = normalise_pron(pron)
                    pron_dict[word].add(pron)

    print("{} pronunciation items collected...".format(len(pron_dict)))

    return pron_dict


def write_lexicon(vocab, outfile, sampa_dict):
    """
    Side effects: produces output file equivalent to 'lexicon.txt'. Multiple pronunciations for the same word are written to their own lines.
    format:
        <word> <pronunciation>

    ** Note **
        words containing multiple tokens in the input vocabulary are expected to be glued together with '_'.

    """

    overflow_file = str(Path(outfile).parent /
                        Path("words_not_found_in_SAMPA.txt"))

    no_pron = Counter()
    line_c = 0
    c = 0
    with open(vocab, "r", encoding="utf8") as inf, open(
        outfile, "w", encoding="utf8"
    ) as outf:
        for line in inf:
            line_c += 1
            vocab_word = line.strip()
            prons = sampa_dict.get(vocab_word.replace("_", " "))
            if prons:
                c += 1
                for pron in prons:
                    outf.write("{} {}\n".format(vocab_word, pron))
            else:
                no_pron[vocab_word] += 1

    print(
        "{} items in vocabulary of length {} have at least 1 pronunciation. ({:.2f}%)".format(
            c, line_c, c / line_c * 100
        )
    )

    with open(overflow_file, "w", encoding="utf8") as overflow:
        print("Writing overflow words to {}".format(overflow_file))
        for k, v in no_pron.items():
            overflow.write("{}\t{}\n".format(k, v))


def main():

    args = get_args()

    sampa_dict = read_sampa_dict(args.sampa_files, args.col_n, args.random)

    # with open(args.outfile, 'w', encoding='utf8') as outf:
    #     for k, v in sampa_dict.items():
    #         for p in v:
    #             # if '_' in p:
    #             #     print(k, p)
    #             outf.write('{} {}\n'.format(k, p))

    if args.vocabulary:
        write_lexicon(args.vocabulary, args.outfile, sampa_dict)

    # simply extract sampa for a given dialect/group

    else:
        with open(args.outfile, "w", encoding="utf8") as outf:
            for k in sorted(sampa_dict.keys()):
                for pron in sampa_dict[k]:
                    outf.write('{} {}\n'.format(k, pron))


if __name__ == "__main__":
    main()
