#!/usr/bin/python3
# -*- coding: utf-8 -*-


"""
Counts the number of OOV items in transcriptions

Example call:
    python3 /mnt/tannon/my_scripts/count_oov.py -l
    /mnt/tannon/processed/archimob_r1/sampa/am_out/initial_data/ling/lexicon.txt
    /mnt/tannon/processed/archimob_r1/sampa/eval_out/lang/text

tannon@kaldi:/mnt/tannon$ python3 /mnt/tannon/my_scripts/count_oov.py -l /mnt/tannon/processed/archimob_r1/sampa/am_out/initial_data/ling/lexicon.txt -t /mnt/tannon/processed/archimob_r1/sampa/eval_out/lang/text

Types in /mnt/tannon/processed/archimob_r1/sampa/eval_out/lang/text: 2264
OOV total: 895 [ 39.53% ]

tannon@kaldi:/mnt/tannon$ python3 /mnt/tannon/my_scripts/count_oov.py -l /mnt/tannon/processed/archimob_r1/norm/am_out/initial_data/ling/lexicon.txt -t /mnt/tannon/processed/archimob_r1/norm/eval_out/lang/text

Types in /mnt/tannon/processed/archimob_r1/norm/eval_out/lang/text: 2264
OOV total: 557 [ 24.60% ]

tannon@kaldi:/mnt/tannon$ python3 /mnt/tannon/my_scripts/count_oov.py -l /mnt/tannon/processed/archimob_r1/orig/am_out/initial_data/ling/lexicon.txt -t /mnt/tannon/processed/archimob_r1/orig/baseline/eval_out/lang/text

Types in /mnt/tannon/processed/archimob_r1/orig/baseline/eval_out/lang/text: 3119
OOV total: 1001 [ 32.09% ]

"""
import argparse
from collections import defaultdict, Counter


def set_args():
    ap = argparse.ArgumentParser()

    ap.add_argument("-l", required=True, help="lexicon file")

    ap.add_argument("-t", required=True, help="test file transcriptions")

    ap.add_argument("--verbose", required=False,
                    default=False, action="store_true")

    return ap.parse_args()


def collect_transcription_vocab(transcription_file):
    """
    1007_E-1007-0003        ja
    1007_E-1007-0028        und kost und das schlafen
    1007_E-1007-0035        glaube ich ein_klein organisiert <SIL_WORD> auf ...
    """

    words = Counter()

    with open(transcription_file, "r", encoding="utf8") as file:
        for line in file:
            utt_id, utt = line.strip().split("\t")

            for token in utt.split():
                words[token] += 1

    return words


def collect_lexicon(lexicon_file):

    lexemes = set()

    with open(lexicon_file, "r", encoding="utf8") as file:
        for line in file:
            line = line.strip().split()
            # if line[0] not in ["<NOISE>", "<SIL_WORD>", "<SPOKEN_NOISE>"]:
            lexemes.add(line[0])

    return lexemes


if __name__ == "__main__":

    args = set_args()
    vocab = collect_transcription_vocab(args.t)
    lexicon = collect_lexicon(args.l)

    # compare
    oov = defaultdict(int)

    for k in vocab.keys():
        if k not in lexicon:
            oov[k] = vocab[k]

    token_c = sum(vocab.values())
    type_c = len(vocab)
    # The closer the TTR ratio is to 1, the greater the lexical richness of the segment.
    print()
    print("Total words in {}: {}".format(args.t, token_c))
    print("Word-from Types in {}: {}".format(args.t, type_c))
    print("Type-Token Ratio: {:.2f}".format(type_c/token_c))

    oov_types = len(oov)
    oov_ratio = (len(oov) / len(vocab))

    print("OOV Types in {}: {}".format(args.t, oov_types))
    print("OOV Ratio: {: .2f}".format(oov_ratio))
    print()
    if args.verbose:
        print("###")
        print("OOV words:")
        for k in oov.keys():
            print("\t", k, "\t", vocab[k])
        print("###")

    # print("OOV total: {} [ {:.2f}% ]".format(
    #     len(oov), ))
    # print()
    # if args.verbose:
    #     print("###")
    #     print("OOV words:")
    #     for k in oov.keys():
    #         print("\t", k, "\t", vocab[k])
    #     print("###")
