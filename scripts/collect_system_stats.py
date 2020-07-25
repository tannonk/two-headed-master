#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Script reads in relevant files and collects stats for an ASR
system based on universal files.

Example call:

    python3 /mnt/tannon/processed/archimob_r1/orig/am_out \
        /mnt/tannon/processed/archimob_r1/orig/baseline/lw_out \
        /mnt/tannon/processed/archimob_r1/orig/baseline/eval_out
"""

import sys
from pathlib import Path
from collections import Counter, defaultdict


def normal_lc(file):
    with open(str(file), "r") as f:
        return sum([1 for line in f])


def uniq_lc(file):
    lines = set()
    with open(str(file), "r") as f:
        for line in f:
            lines.add(hash(f))
    return len(lines)


def count_audio(file):
    """
    file: utt2dur file
    """

    total = 0

    with open(str(file), "r", encoding="utf8") as f:
        for line in f:
            line = line.strip().split(" ")
            try:
                dur = float(line[-1])
                total += dur
            except ValueError:
                pass
    return total / 60 / 60


def inspect_lexicon(file):
    """
    file: lexicon.txt file (pronunciation)
    """
    lex = defaultdict(set)

    with open(str(file), "r", encoding="utf8") as f:
        for line in f:
            line = line.split()
            lexeme = line[0]
            pron = " ".join(line[1:])
            lex[lexeme].add(pron)

    # av_ratio = len(lex) / sum([len(v) for v in lex.values()])
    return len(lex), sum([len(v) for v in lex.values()])


def main():

    am_dir = Path(sys.argv[1])
    # lw_dir = Path(sys.argv[2])
    # ev_dir = Path(sys.argv[3])

    stats = dict()

    ## Count vocab length, lexicon items x pronunciation variants, phone set
    vocab_file = am_dir / Path("initial_data/tmp/vocabulary.txt")
    lexicon_file = am_dir / Path("initial_data/ling/lexicon.txt")
    phones_file = am_dir / Path("initial_data/ling/nonsilence_phones.txt")

    ## Training utterances
    train_utterances = am_dir / Path("initial_data/data/text")
    utt2dur_file = am_dir / Path("initial_data/data/utt2dur")
    utt2spk_file = am_dir / Path("initial_data/data/utt2spk")

    ## Development utterances
    # dev_utterances = lw_dir / Path("lang/text")
    # utt2spk_file = lw_dir / Path("lang/utt2spk")

    ## Test utterances
    # test_utterances = ev_dir / Path("lang/text")
    # test_utt2spk_file = ev_dir / Path("lang/utt2spk")

    stats["training vocabulary size"] = normal_lc(vocab_file)
    l, p = inspect_lexicon(lexicon_file)
    stats["lexemes in lexicon"] = l
    stats["pronunciations in lexicon"] = p
    stats["pronunciation variance"] = p / l
    stats["phonemes"] = normal_lc(phones_file)
    stats["audio data"] = count_audio(utt2dur_file)

    # dev_size = normal_lc(dev_utterances)

    for k, v in stats.items():
        print(k, "\t", v)


if __name__ == "__main__":
    main()
