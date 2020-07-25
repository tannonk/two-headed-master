#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Script takes SAMPA csv files as input and produces a JSON
file containing lexemes and their corresponding
SAMPA pronunciation annotation.

For all possible pronunciations, example call is:
    python3
    /home/tannon/my_scripts/create_norm2sampa_dictionary.py
    -s /mnt/tannon/corpus_data/SAMPA/*
    -o /mnt/tannon/corpus_data/norm2sampa.json

If only one pronunciation form is desired, either select the
column corresponding to that particular dialect in the csv
with the --col_n argument, or provide the --random argument
to get a single random pronunciation variant for exh lexeme.

The columns of the SAMPA csv files are:
column 1: Standard German words in normal (latin) writing
column 2: Zurich
column 3: St. Gallen
column 4: Basel
column 5: Bern
column 6: Wallis
column 7: Nidwalden
column 8: GSWs (Swiss German in latin writing), received
from Swisscom

"""

import sys
import re
import argparse
import random
from pathlib import Path
from collections import defaultdict, Counter
import json


def get_args():
    """
    Returns the command line arguments
    """

    parser = argparse.ArgumentParser()

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

    parser.add_argument("--outfile", "-o", help="Output lexicon", required=True)

    args = parser.parse_args()

    return args


def read_sampa_dict(sampa_files, col_num=0, rand=False):
    """
    Reads all SAMPA files provided to create a dictionary
    with a gsw word as a key and the set of all possible
    pronunciations as a value for that key.
    
    sampa_files: list of SAMPA annotated files
    col_num (int): number of column to take
    """

    sampa_dict = defaultdict(set)

    for file in sampa_files:
        with open(file, "r", encoding="utf8") as f:
            for line in f:
                line = line.rstrip("\n").split("\t")
                # normalised word
                word = line[0].strip()
                word = re.sub(" ", "_", word)
                word = re.sub("_(LXA|MRA)", "", word)
                word = word.strip()

                if col_num:
                    prons = [line[col_num - 1]]
                else:
                    prons = set(line[1:7])

                    if rand:
                        prons = [random.choice(list(prons))]

                for pron in prons:
                    pron = pron.rstrip().lstrip()
                    pron = re.sub(r"_", "", pron)
                    pron = re.sub(r"\s+", r" ", pron)
                    sampa_dict[word].add(pron)

    for k, v in sampa_dict.items():
        if len(v) > 1:
            print(k, v)

    print("{} normalised forms found.".format(len(sampa_dict)))
    sampa_forms = sum([len(v) for v in sampa_dict.values()])
    print("{} SAMPA pronunciation forms found.".format(sampa_forms))

    # convert set to list to write out as JSON
    sampa_dict = {k: list(v) for k, v in sampa_dict.items()}

    return sampa_dict


if __name__ == "__main__":

    args = get_args()
    # sampa_files = [
    #     str(f) for f in Path(args.sampa_files).iterdir() if "small" in f.name
    # ]

    sampa_dict = read_sampa_dict(args.sampa_files, args.col_n, args.random)

    with open(args.outfile, "w", encoding="utf8") as outf:
        json.dump(sampa_dict, outf, indent=4, ensure_ascii=False, sort_keys=True)
