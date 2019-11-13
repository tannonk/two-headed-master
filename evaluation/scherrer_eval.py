#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
This script scores a hypothesis transcription against a reference for precision, recall and f1, similar to [Scherrer et al. 2019]. Flexible overlap is calculated by looking at the normalised form of a hypothesis word to see if the word has been transcribed in the same way elsewhere in the corpus, as suggested by Tanja Samardžić.

Example call:

    python3 scherr_eval.py \
    --ref /mnt/tannon/processed/archimob_r1/orig/decode_out/decode/scoring_kaldi/test_filt.txt \
    --hyp /mnt/tannon/processed/archimob_r1/orig/decode_out/decode/scoring_kaldi/penalty_0.0/7.txt \
    -d /mnt/tannon/corpus_data/norm2dieth.json

"""

__Author__: "Tannon Kew"
__Email__: "tannon.kew@uzh.ch"
__Date__: "13.11.19"

import sys
import argparse
import random # for debugging
import json
from collections import defaultdict

def set_args():
    ap = argparse.ArgumentParser()

    ap.add_argument('--ref', required=True, help='file containing reference transcriptions of test set utterances, e.g. /mnt/tannon/processed/archimob_r1/orig/decode_out/decode/scoring_kaldi/test_filt.txt (created during uzh/score.sh)')

    ap.add_argument('--hyp', required=True, help='file containing system output transcriptions of test set utterances, e.g. /mnt/tannon/processed/archimob_r1/orig/decode_out/decode/scoring_kaldi/penalty_0.0/7.txt (created during decoding)')

    ap.add_argument('-d', '--n2d_map', required=True, help='JSON file containing a mapping of all normalised word forms with all Dieth transcriptions corresponding to each normalised word form, e.g. /mnt/tannon/corpus_data/norm2dieth.json (created with /home/tannon/my_scripts/create_norm2dieth_dictionary.py)')

    ap.add_argument('-v', '--verbose', required=False, default=0, type=int, help='level of verbosity')

    return ap.parse_args()

############################################################################

def quick_lc(inf):
    with open(inf, 'rb') as f:
        return sum([1 for line in f])

def get_mappings(n2d_map_file, verbose=0):
    """
    Converts norm2dieth mapping to dieth2norm mapping, which speeds up searches for Dieth transcription word forms produced in decoding.
    """
    d2n_map = defaultdict(set)
    duplicates = 0
    with open(n2d_map_file, 'r', encoding='utf8') as f:
        n2d_map = json.load(f)
        for k, v in n2d_map.items():
            for w in v:
                d2n_map[w].add(k)


    if verbose >= 3:
        print('\nNORM-TO-DIETH mapping sample:')
        sample_keys = random.sample(list(n2d_map), 10)
        for k in sample_keys:
            print(f'{k}\t{n2d_map[k]}')


        print('\nDIETH-TO-NORM mapping sample:')
        sample_keys = random.sample(list(d2n_map), 10)
        for k in sample_keys:
            print(f'{k}\t{d2n_map[k]}')

        multiple_values = sum([1 for v in d2n_map.values() if len(v) > 1])

        print(f'\nWARNING: {multiple_values} Dieth transcriptions have multiple corresponding normalised transcriptions.\n')

    return n2d_map, d2n_map

def normalise_utterance(utt):
    utt = utt.replace('<SPOKEN_NOISE>', '')
    utt = utt.replace('<SIL_WORD>', '')
    return utt.split()

def calulate_flexible_overlap(n2d_map, d2n_map, ref, hyp, verbose=0):
    """
    Flexible overlap provides allowable variability in the hypothesis and is calculated on the basis of a given normalised form and its set of possible Dieth transcription surface forms.

    Args:
        n2d_map: dictionary object with normalised word forms as keys
        d2n_map: dictionary object with Dieth word forms as keys
        ref: reference transcription as list of strings
        hyp: system output/hypothesis transcription as list of strings
    """

    flexible_overlap = 0
    true_overlap = 0

    for hyp_idx, hyp_wrd in enumerate(hyp):
        if hyp_wrd in ref:
            true_overlap += 1
            # print(f'FOUND: {hyp_wrd} in {ref}')
            ref_idx = ref.index(hyp_wrd)
            ref[ref_idx] = ref[ref_idx]+'##T'+str(true_overlap)
            hyp[hyp_idx] = hyp[hyp_idx]+'@@T'+str(true_overlap)
        else:
            # print(hyp_wrd, 'not found in', ref)
            # get normalised candidates
            norm_candidates = d2n_map[hyp_wrd]

            # print('\tNORM CANDIDATES', norm_candidates)

            valid_forms = set()
            for candidate in norm_candidates:
                valid_forms.add(candidate)
                for form in n2d_map[candidate]:
                    valid_forms.add(form)
            # print('\tVALID SURFACE FORMS', valid_forms)
            for ref_idx, ref_wrd in enumerate(ref):
                if ref_wrd in valid_forms:
                    flexible_overlap += 1
                    # print(f'FOUND: {ref_wrd} in {valid_forms}')
                    ref[ref_idx] = ref[ref_idx]+'##F'+str(flexible_overlap)
                    hyp[hyp_idx] = hyp[hyp_idx]+'@@F'+str(flexible_overlap)
                    # print(f'MARKED: {ref_wrd} {ref[ref_idx]}')
                    break # end inner for loop and continue with next hypothesis word

    return flexible_overlap, true_overlap


def calculate_precision(overlap, hypothesis_length):
    """
    Precision is expressed as the proportion of correct word tokens, including the flexible overlap, in the system output: (S+F)/O
    Args:
        overlap: total overlap as counted with calulate_flexible_overlap()
        hypothesis_length: list of tokens in hypothesis (system output)
    """
    # avoid division by zero error
    if hypothesis_length == 0:
        return 0
    else:
        return overlap / hypothesis_length

def calculate_recall(overlap, reference_length):
    """
    Recall is the proportion of words correctly recognised by the system in the gold transcription: (S+F)/T
    Args:
        overlap: total overlap as counted with calulate_flexible_overlap()
        reference_length: number of tokens in reference (ground truth transcription)
    """
    # avoid division by zero error
    if reference_length == 0:
        return 0
    else:
        return overlap / reference_length

def calculate_f1(precision, recall):
    """
    Harmonic mean of precision and recall: 2 * (prec * rec) / (prec + rec)
    """
    # avoid division by zero error
    if precision + recall == 0:
        return 0
    else:
        f1 = 2 * (precision * recall) / (precision + recall)
        return f1

def collect_references(ref_file):
    """
    Expects a txt/tsv file with <utterance ID>\t<utterance string>

    1300_SPK0-1300-0001     <SIL_WORD>
    1300_SPK0-1300-0002     <SPOKEN_NOISE>
    1300_SPK0-1300-0003     <SPOKEN_NOISE>
    1300_SPK0-1300-0004     wämmer gad <SPOKEN_NOISE> so afoo dass sii sich <SPOKEN_NOISE> vorschtelled wär sii sind und wiä sii haissed
    """
    ref_dict = {}
    with open(ref_file, 'r', encoding='utf8') as f:
        for line in f:
            line_lst = line.split('\t')
            utt_id = line_lst[0]
            utterance = normalise_utterance(line_lst[1])
            ref_dict[utt_id] = utterance
    return ref_dict

#########################################################################

def main():

    args = set_args()

    n2d_map, d2n_map = get_mappings(args.n2d_map, verbose=args.verbose)

    # control whether ref file and hyp file are a valid pair based on number of lines
    if quick_lc(args.ref) != quick_lc(args.hyp):
        sys.exit(f'{args.ref} does not have the same number of lines as {args.hyp}!')

    # collect reference transcriptions and store them in a dictionary
    refs = collect_references(args.ref)

    total_hyp_words = 0
    total_flex = 0
    total_real = 0
    total_p = 0
    total_r = 0
    total_f = 0

    with open(args.hyp, 'r', encoding='utf8') as f:
        for n, line in enumerate(f):
            line_lst = line.rstrip().split(' ')
            utt_id = line_lst[0]
            ref = refs[utt_id] # lookup relevant reference transcription
            hyp = line_lst[1:]

            # increment total hypothesis words
            hyp_len = len(hyp)
            total_hyp_words += hyp_len
            ref_len = len(ref)


            flex, real = calulate_flexible_overlap(n2d_map, d2n_map, ref.copy(), hyp.copy(), verbose=0)

            total_flex += flex
            total_real += real

            # print(f'FLEX SCORE: {flex}\nREAL SCORE: {real}\nREF: {ref}\nHYP: {hyp}')

            overlap = flex+real

            p = calculate_precision(overlap, hyp_len)
            total_p += p # increment total precision

            r = calculate_recall(overlap, ref_len)
            total_r += r # increment total recall

            f = calculate_f1(p, r)
            total_f += f # increment total f1

            if hyp_len > 0:
                flex_ratio = flex/hyp_len*100
            else:
                flex_ratio = 0

            if args.verbose == 1:
                print(f'%F1: {f:.2f} %P: {p:.2f} %R: {r:.2f} [ %Flex: {flex_ratio:.2f} {flex} / {hyp_len} ]')
            elif args.verbose == 2:
                print(f'%F1: {f:.2f} %P: {p:.2f} %R: {r:.2f} [ %Flex: {flex_ratio:.2f} {flex} / {hyp_len} ID: {utt_id} REF: {" ".join(ref)} HYP: {" ".join(hyp)} ]')

    # calculate averages
    av_p = total_p/n*100
    av_r = total_r/n*100
    av_f = total_f/n*100
    av_flex_ratio = total_flex/total_hyp_words*100

    print(f'%F1: {av_f:.2f} %P: {av_p:.2f} %R: {av_r:.2f} [ %Flex: {av_flex_ratio:.2f} {total_flex} / {total_hyp_words} ]')


if __name__ == '__main__':
    main()
