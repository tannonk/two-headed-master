#!/usr/bin/env python3
# -*- coding: utf8 -*-

import argparse
from pathlib import Path
from lxml import etree, objectify

# from normalswiss import *
import normalswiss

# infile = Path(
#     "/Users/tannon/switchdrive/MA/tannon/data/Transcripts_Phonogrammarchiv/xml/paz.bwe.t01.xml"
# )


def get_args():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", required=True, help="input dir of xml files")
    ap.add_argument("-o", required=True, help="output dir of txt files")
    return ap.parse_args()


def extract_gsw(div_tag, ns_map):

    utterances = []

    for u_tag in div_tag.iter("{" + ns_map[None] + "}u"):
        utt = []
        for w_tag in u_tag.iter("{" + ns_map[None] + "}w"):
            # print(w_tag)
            utt.append(w_tag.text.strip())
        # print(utt)
        utterances.append(" ".join(utt))

    return utterances


# def extract_de(div_tag, ns_map):
#     utterances = []

#     for u_tag in div_tag.iter("{" + ns_map[None] + "}u"):
#         # utt = []
#         # for w_tag in u_tag.iter("{" + ns_map[None] + "}w"):
#         # print(w_tag)
#         # utt.append(w_tag.text.strip())
#         # print(utt)
#         print(u_tag.text)
#         utterances.append(u_tag.text.strip())

#     return utterances


if __name__ == "__main__":

    args = get_args()
    parser = etree.XMLParser(remove_blank_text=True)

    with open(args.o, "w", encoding="utf8") as outf:
        for file in sorted(Path(args.i).iterdir()):
            if file.suffix == ".xml":
                infile = str(file)
                tree = etree.parse(infile, parser)
                ns_map = tree.getroot().nsmap
                # add standard xml namespace to ns mapping
                ns_map["xml_ns"] = "http://www.w3.org/XML/1998/namespace"

                for div in tree.getroot().iter("{" + ns_map[None] + "}div"):
                    if div.attrib.get("{" + ns_map["xml_ns"] + "}lang") == "gsw":
                        gsw_utterances = extract_gsw(div, ns_map)

                if gsw_utterances:
                    for u in gsw_utterances:
                        u = normalswiss.normalise(u)
                        outf.write(u + "\n")

        # elif div.attrib.get("{" + ns_map["xml_ns"] + "}lang") == "deu":
        #     print(div)
        #     de = extract_de(div, ns_map)

