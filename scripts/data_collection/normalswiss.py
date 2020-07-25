#!/usr/bin/python3
# -*- coding: utf-8 -*-


"""
Normalise sentences from gsw-ch_web_2017_100K

Example call:

python3 ~/switchdrive/MA/tannon/working_scripts/normalise_gsw_sents.py gsw-ch_web_2017_100K-sentences-no_meta.txt

"""

import sys
import re
import random


punct = re.compile(
    r"[\!\"\#\$\%\&\'\(\)\*\+\,\-\–\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~\«\‹\›\»\’\‘\“\”\„\…\•\¨\·\◦\○\€\£\°\→]"
)
basic_meta = re.compile(r".*\d\d:\d\d")
list_nums = re.compile(r"\d+?\)")
other_meta = re.compile(r"@CARD@\s+winter\s+sommer\s+alltags\s+arbeitshure")
digits = re.compile(r"(?:\d+(?:\s+)?)+")
list_digit = re.compile(r"^\s+?@CARD@")
urls = re.compile(r"(:?https?\S+?)?www\S+")
card_placeholder = re.compile("@CARD@")
rep_chars = re.compile(r"(\w)\1{4,}")
multi_spaces = re.compile(r"\s+")

archimob_numbers = set(
    [
        "ein",
        "ä",
        "ais",
        "en",
        "echlì",
        "ääs",
        "öi",
        "as",
        "esoo",
        "echli",
        "äin",
        "ereis",
        "i",
        "ei",
        "äint",
        "ec",
        "ääin",
        "em",
        "ai",
        "e",
        "es",
        "in",
        "äs",
        "eso",
        "is",
        "ääi",
        "èchli",
        "ehau",
        "eint",
        "aso",
        "nes",
        "äis",
        "öies",
        "ebiz",
        "aai",
        "eis",
        "än",
        "ììn",
        "echlä",
        "a",
        "äi",
        "ein",
        "eine",
        "äinti",
        "äine",
        "ei",
        "ä",
        "äint",
        "ääinti",
        "sone",
        "aine",
        "einä",
        "en",
        "èini",
        "iine",
        "eso",
        "äini",
        "än",
        "eini",
        "ainti",
        "dini",
        "ainä",
        "ai",
        "eich",
        "a",
        "e",
        "enä",
        "aii",
        "ine",
        "öie",
        "emme",
        "ne",
        "esää",
        "ain",
        "an",
        "eint",
        "es",
        "äi",
        "ane",
        "in",
        "ääine",
        "äiné",
        "äin",
        "ein",
        "nes",
        "einti",
        "i",
        "ufene",
        "ene",
        "ììne",
        "aaine",
        "aint",
        "aini",
        "zwei",
        "zwe",
        "zwä",
        "zwìì",
        "zweimol",
        "zwoo",
        "zwoi",
        "zwai",
        "zwöi",
        "zwo",
        "zwee",
        "zwaai",
        "zweg",
        "zwääi",
        "zwei",
        "zwäi",
        "drei",
        "dräi",
        "dri",
        "dreei",
        "drìì",
        "drèi",
        "dreimol",
        "drei",
        "dree",
        "drü",
        "drii",
        "dre",
        "drüü",
        "trii",
        "drai",
        "vier",
        "viere",
        "viir",
        "viier",
        "vir",
        "vieri",
        "viär",
        "vier",
        "fünf",
        "füüff",
        "feif",
        "füf",
        "fif",
        "föifi",
        "fünfi",
        "füüfi",
        "füfe",
        "fiif",
        "füüf",
        "füfi",
        "fümf",
        "föif",
        "fòif",
        "fünf",
        "füüfs",
        "foif",
        "sechs",
        "sächsi",
        "seggs",
        "säggsch",
        "sèchs",
        "sächs",
        "säch",
        "säggs",
        "säächs",
        "sääggsch",
        "sächse",
        "sieben",
        "sibäne",
        "sììbe",
        "sibä",
        "siben",
        "siibe",
        "sind",
        "sibemol",
        "siibni",
        "sibe",
        "siiben",
        "sibän",
        "sibni",
        "sìbe",
        "sìben",
        "siiged",
        "acht",
        "acht",
        "achti",
        "nein",
        "nanei",
        "neid",
        "nöi",
        "ni",
        "nnai",
        "nänäi",
        "näai",
        "nanaii",
        "näe",
        "nain",
        "näne",
        "nänääi",
        "nai",
        "neei",
        "nanai",
        "nainai",
        "naime",
        "nài",
        "noii",
        "nääi",
        "naii",
        "ne",
        "nnäi",
        "nanaai",
        "nì",
        "nen",
        "nanana",
        "nana",
        "nei",
        "näin",
        "nes",
        "naai",
        "nääie",
        "nanäi",
        "naa",
        "na",
        "näinäi",
        "zehn",
        "zääni",
        "zä",
        "zèè",
        "zee",
        "zää",
        "zächni",
        "zäni",
        "zeen",
        "zeni",
    ]
)


def normalise(line):
    """Normalises an input utterance/sentence"""

    line = line.strip().lower()
    line = re.sub(urls, " www ", line)  # remove URLs
    line = re.sub(basic_meta, "", line)  # remove basic meta data
    line = re.sub(list_nums, "", line)  # remove list numbers such as '1)'
    line = re.sub(punct, " ", line)  # replace and split on punctuation
    line = re.sub(digits, " @CARD@ ", line)  # replace digits with placeholder
    line = re.sub(list_digit, "", line)  # remove digits from start of line
    line = re.sub(card_placeholder, random.choice(list(archimob_numbers)), line)
    line = re.sub(other_meta, "", line)
    line = re.sub(rep_chars, r"\1\1\1", line)  # normalise repeated chars
    line = re.sub(multi_spaces, " ", line)  # normalise whitespaces
    line = line.strip()

    return line


if __name__ == "__main__":
    pass


# infile = sys.argv[1]
# outfile = infile.replace('.txt', '.norm.txt')

# seen_sentences = set()

# with open(infile, 'r', encoding='utf8') as inf:
#     with open(outfile, 'w', encoding='utf8') as outf:
#         for line in inf:
#             # remove meta data
#             line = line.strip().lower()
#             line = re.sub(urls, ' www ', line) # remove URLs
#             line = re.sub(basic_meta, '', line) # remove basic meta data
#             line = re.sub(list_nums, '', line) # remove list numbers such as '1)'
#             line = re.sub(punct, ' ', line) # replace and split on punctuation
#             line = re.sub(digits, ' @CARD@ ', line) # replace digits with placeholder
#             line = re.sub(list_digit, '', line) # remove digits from start of line
#             line = re.sub(card_placeholder, random.choice(list(archimob_numbers)), line)
#             line = re.sub(other_meta, '', line)
#             line = re.sub(rep_chars, r'\1\1\1', line) # normalise repeated chars
#             line = re.sub(multi_spaces, ' ', line) # normalise whitespaces
#             line = line.strip()


#             if line and hash(line) not in seen_sentences:
#                 outf.write('{}\n'.format(line))
#                 seen_sentences.add(hash(line))

