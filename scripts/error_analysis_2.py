#!/usr/bin/python3
#! -*- coding: utf-8 -*-

import sys
from collections import Counter, defaultdict, OrderedDict
import argparse
import re
import json
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import numpy as np

def set_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('-ref', required=True,
                    help='File containing reference transcripions.')
    ap.add_argument('-hyp', required=True,
                    help='File containing system output hypotheses.')
    ap.add_argument('-m', '--n2d_mapping', required=False,
                    help='If provided, flexible WER is calculated based on forms found in mapping.')
    ap.add_argument('-p', '--plot', required=True, help='name of output plot.')

    ap.add_argument('--verbose', required=False, action='store_true',
                    help='if provided, line by line results are printed.')


    ap.add_argument('-l', '--lex',  required=True,
                    help='System lexicon.')


    return ap.parse_args()


def normalise_line(line):
    line = re.sub(r'^\S+?(\s|\t)', '', line)
    line = re.sub(r'\s+', ' ', line)
    return line.strip()


def align_pretty(source, target, outfile=sys.stdout):
    """
    Pretty-print the alignment of two sequences of strings.
    """
    i, j = 0, 0
    lines = [[] for _ in range(4)]  # 4 lines: source, bars, target, codes
    for op in opcodes(source, target):
        # print(code)
        op = op.upper()
        s, t = source[i], target[j]
        if op == 'D':  # Deletion: empty string on the target side
            t = '*'
        elif op == 'I':  # Insertion: empty string on the source side
            s = '*'
        elif op == 'E':  # Equal: omit the code
            op = ' '

        # Format all elements to the same width.
        width = max(len(x) for x in (s, t, op))
        for line, token in zip(lines, [s, '|', t, op]):
            line.append(token.center(width))  # pad to width with spaces

        # Increase the counters depending on the operation.
        if op != 'D':  # proceed on the target side, except for deletion
            j += 1
        if op != 'I':  # proceed on the source side, except for insertion
            i += 1

    # Print the accumulated lines.
    for line in lines:
        print(*line, file=outfile)


def opcodes(source, target, n2d_map=None, d2n_map=None):
    """
    Get a list of edit operations for converting source into target.
    """
    n = len(source)
    m = len(target)
    # Initisalise matrix with values None.
    d = [[None for _ in range(m+1)] for _ in range(n+1)]

    d[0][0] = 0

    # Fill in first collumn.
    for i in range(1, n+1):
        d[i][0] = d[i-1][0] + 1

    # Fill in first row.
    for j in range(1, m+1):
        d[0][j] = d[0][j-1] + 1

    # Fill in matrix
    for i in range(1, n+1):
        for j in range(1, m+1):

            if not d2n_map:
                d[i][j] = min(
                    d[i-1][j] + 1,  # del
                    d[i][j-1] + 1,  # ins
                    d[i-1][j-1] + (1 if source[i-1] !=
                                   target[j-1] else 0)  # sub
                )

            else:
                norm_forms = d2n_map[target[j-1]]

                dieth_forms = set()
                for f in norm_forms:
                    for dieth_form in n2d_map[f]:
                        dieth_forms.add(dieth_form)

                d[i][j] = min(
                    d[i-1][j] + 1,  # del
                    d[i][j-1] + 1,  # ins
                    d[i-1][j-1] + (1 if source[i-1]
                                   not in dieth_forms else 0)  # sub
                )

    # Get list of operations from backtrace function.
    return backtrace(d)


def backtrace(d):
    i = len(d) - 1
    j = len(d[0]) - 1
    steps = []

    # While not in the top left cell, calculate the cheapest step and when found move to that cell and insert operation to steps list.

    while i > 0 and j > 0:
        cheapest_step = min(d[i-1][j-1], d[i][j-1], d[i-1][j])

        if cheapest_step == d[i-1][j-1]:
            if d[i-1][j-1] == d[i][j]:
                steps.insert(0, "e")  # cell to upper left is equal
                i -= 1
                j -= 1
                continue

            else:
                steps.insert(0, "s")  # cell to upper left is cheapest via sub
                i -= 1
                j -= 1
                continue

        # Cell to left is min
        elif cheapest_step == d[i][j-1]:
            steps.insert(0, "i")
            j -= 1
            continue

        # Cell above is min
        elif cheapest_step == d[i-1][j]:
            steps.insert(0, "d")
            i -= 1
            continue

    # Moving up (no cell to the left)
    if i > 0 and j == 0:
        for i in reversed(range(i)):
            steps.insert(0, "d")
            i -= 1

    # Moving left (no cell above)
    if i == 0 and j > 0:
        for j in reversed(range(j)):
            steps.insert(0, "i")
            j -= 1

    return steps


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
            print('{}\t{}'.format(k, n2d_map[k]))

        print('\nDIETH-TO-NORM mapping sample:')
        sample_keys = random.sample(list(d2n_map), 10)
        for k in sample_keys:
            print('{}\t{}'.format(k, d2n_map[k]))

        multiple_values = sum([1 for v in d2n_map.values() if len(v) > 1])

        print('\nWARNING: {} Dieth transcriptions have multiple corresponding normalised transcriptions.\n'.format(
            multiple_values))

    return n2d_map, d2n_map


# def align_pretty(source, target, lexicon=None, n2d_map=None, d2n_map=None, outfile=sys.stdout):
#     """
#     Pretty-print the alignment of two sequences of strings.
#     """
#     i, j = 0, 0
#     lines = [[] for _ in range(4)]  # 4 lines: source, bars, target, codes

#     # skip if ref is empty
#     if len(source) == 0:
#         return None

#     if n2d_map and d2n_map:
#         ops = opcodes(source, target, n2d_map, d2n_map)
#     else:
#         ops = opcodes(source, target)

#     # print(ops)
#     # ops = opcodes(source, target)

#     errors = OrderedDict()

#     categories = [
#         'ins',
#         'OOV_del',
#         'INV_del',
#         'OOV_sub',
#         'INV_sub',
#         # 'OVV_cor',
#         # 'INV_cor'
#     ]

#     for i in categories:
#         errors[i] = 0

#     for code in ops:
#         try:
#             code = code[0].upper()
#             s, t = source[i], target[j]
#             if code == 'D':  # Deletion: empty string on the target side
#                 t = '***'
#                 if lex:
#                     if not s in lex:
#                         errors['OOV_del'] += 1
#                     else:
#                         errors['INV_del'] += 1

#             elif code == 'I':  # Insertion: empty string on the source side
#                 s = '***'
#                 if lex:
#                     errors['ins'] += 1

#             elif code == 'S':
#                 if not s in lex:
#                     errors['OOV_sub'] += 1
#                 else:
#                     errors['INV_sub'] += 1

#             elif code == 'E':  # Equal: omit the code
#                 code = 'C'

#             # Format all elements to the same width.
#             width = max(len(x) for x in (s, t, code))
#             for line, token in zip(lines, [s, '|', t, code]):
#                 line.append(token.center(width))  # pad to width with spaces

#             # Increase the counters depending on the operation.
#             if code != 'D':  # proceed on the target side, except for deletion
#                 j += 1
#             if code != 'I':  # proceed on the source side, except for insertion
#                 i += 1
#         except IndexError:
#             pass

#     # Print the accumulated lines.
#     for line in lines:
#         print(*line, file=outfile)


def read_lexicon(file):
    lex = set()
    with open(str(file), 'r', encoding='utf8') as f:
        for line in f:
            line = line.split()
            lex.add(line[0].strip())
    return lex

def plot2(d, outfile):

    fig, ax = plt.subplots()

    pieValues = d.values()

    wedges, texts = ax.pie(
        pieValues,
        # colors=colors,
        # explode=explode,
        # autopct='%1.1f%%',
        # startangle=90,
        # wedgeprops={'linewidth': 0.5, 'edgecolor': 'black'}
        # pctdistance=0.85
    )

    ax.set_aspect('equal')
    ax.axis('off')
    
    groups = [[0], [1, 2], [3, 4]]

    radfraction = 0.1
    patches = []
    for i in groups:
        # print((wedges[i[-1]].theta2 + wedges[i[0]].theta1)/2)
        ang = np.deg2rad((wedges[i[-1]].theta2 + wedges[i[0]].theta1)/2,)
        print(ang)
        for j in i:
            we = wedges[j]
            print(we)
            print(ang)
            center = (radfraction*we.r*np.cos(ang), radfraction*we.r*np.sin(ang))
            patches.append(mpatches.Wedge(center, we.r, we.theta1, we.theta2))

    # # print(patches)

    # colors = ['#E26882', '#EDC363', '#5EC3E5', '#47E0B7', '#A273CE']
    colors = np.linspace(0, 1, len(patches))
    collection = PatchCollection(patches, cmap=plt.cm.hsv)
    collection.set_array(np.array(colors))
    collection = PatchCollection(patches)
    ax.add_collection(collection)
    ax.autoscale(True)

    fig.tight_layout()
    # plt.savefig(outfile, dpi=300, format=None)
    plt.savefig(outfile)

def plot(d, outfile):

    plt.rcParams.update({'hatch.color': 'w'})
    # The slice names of a population distribution pie chart

    # pieLabels = d.keys()
    pieLabels = [
        'Ins',
        'Del (OOV)',
        'Del (in)',
        'Sub (OOV)',
        'Sub (in)'
    ]

    pieValues = d.values()

    fig, ax = plt.subplots()

    # add colors
    # colors = ['#9F71C9', '#49E1B9', '#51A9C7', '#E8CD8F', '#F99AAE']
    # colors = ['#E26882', '#EDC363', '#5EC3E5', '#47E0B7', '#A273CE']

    colors = ['#ffcd38', '#38f8ff', '#38f8ff', '#ff3898', '#ff3898']

    # explsion
    explode = (0.0, 0.1, 0.0, 0.1, 0.0)

    chart = ax.pie(
        pieValues,
        colors=colors,
        labels=pieLabels,
        # explode=explode,
        autopct='%1.1f%%',
        startangle=-30,
        wedgeprops={'linewidth': 0.5, 'edgecolor': 'white'},
        textprops={'size': 'large'}
        # pctdistance=0.85
    )

    # fill slices
    chart[0][1].set_hatch('/')
    chart[0][3].set_hatch('/')

    fig.tight_layout()
    plt.savefig(outfile, dpi=300, format=None)


if __name__ == "__main__":

    args = set_args()

    if args.lex:
        lex = read_lexicon(args.lex)
    else:
        lex = None

    if args.n2d_mapping:
        n2d_map, d2n_map = get_mappings(args.n2d_mapping)
    else:
        n2d_map, d2n_map = None, None

    total_ops = Counter()
    # total_score = 0
    line_count = 0

    ref_utts = defaultdict(list)

    with open(args.ref, 'r', encoding='utf8') as r_file:
        for line in r_file:
            line_list = re.split(r'\s+', line.strip())
            ref_utts[line_list[0]] = line_list[1:]

    errors = OrderedDict()

    categories = [
        'ins',
        'OOV_del',
        'INV_del',
        'OOV_sub',
        'INV_sub',
        # 'OVV_cor',
        # 'INV_cor'
    ]

    for i in categories:
        errors[i] = 0

    with open(args.hyp, 'r', encoding='utf8') as h_file:
        for line in h_file:
            line_count += 1
            line_list = re.split(r'\s+', line.strip())
            utt_id = line_list[0]
            target = line_list[1:]
            source = ref_utts[utt_id]

            i, j = 0, 0
            # 4 lines: source, bars, target, codes
            lines = [[] for _ in range(4)]

            # skip if ref is empty
            if len(source) == 0:
                continue

            if n2d_map and d2n_map:
                ops = opcodes(source, target, n2d_map, d2n_map)
            else:
                ops = opcodes(source, target)

            for op in ops:
                try:
                    op = op[0].upper()
                    s, t = source[i], target[j]
                    if op == 'D':  # Deletion: empty string on the target side
                        t = '***'
                        if lex:
                            if not s in lex:
                                errors['OOV_del'] += 1
                            else:
                                errors['INV_del'] += 1

                    elif op == 'I':  # Insertion: empty string on the source side
                        s = '***'
                        if lex:
                            errors['ins'] += 1

                    elif op == 'S':
                        if not s in lex:
                            errors['OOV_sub'] += 1
                        else:
                            errors['INV_sub'] += 1

                    elif op == 'E':  # Equal: omit the code
                        op = 'C'

                    # Format all elements to the same width.
                    width = max(len(x) for x in (s, t, op))
                    for line, token in zip(lines, [s, '|', t, op]):
                        # pad to width with spaces
                        line.append(token.center(width))

                    # Increase the counters depending on the operation.
                    if op != 'D':  # proceed on the target side, except for deletion
                        j += 1
                    if op != 'I':  # proceed on the source side, except for insertion
                        i += 1
                
                except IndexError:
                    pass

    print()
    print('Errors:')
    # print()
    for e in errors:
        print('\t{}\t{}'.format(e, errors[e]))
    # print(errors)
    print()

    plot(errors, args.plot)

            # Print the accumulated lines.
            # for line in lines:
                # print(*line, file=outfile)

            # align_pretty(ref_utts[utt_id], hyp_utt, lex, n2d_map, d2n_map)
            # # skip if ref is empty
            # if len(ref_utts[utt_id]) == 0:
            #     continue

            # if n2d_map and d2n_map:
            #     ops = opcodes(ref_utts[utt_id], hyp_utt, n2d_map, d2n_map)
            # else:
            #     ops = opcodes(ref_utts[utt_id], hyp_utt)

            # print(ops)

    #         if args.verbose:
    #             ops = Counter(ops)
    #             # line_error = (ops['d'] + ops['s'] + ops['i']) / sum(ops.values())
    #             line_error = (ops['d'] + ops['s'] + ops['i']) / \
    #                 (ops['d'] + ops['s'] + ops['e'])

    #             pp_ops = str(ops['e']) + ' ' + str(ops['s']) + \
    #                 ' ' + str(ops['i']) + ' ' + str(ops['d'])
    #             print('{}\t{}\n{}\t{}\n{}\t#csid {}\t{:.2f}%'.format(utt_id,
    #                                                                  ' '.join(
    #                                                                      ref_utts[utt_id]),
    #                                                                  utt_id,
    #                                                                  ' '.join(
    #                                                                      hyp_utt),
    #                                                                  utt_id,
    #                                                                  pp_ops,
    #                                                                  line_error*100))

    #         total_ops += Counter(ops)
    #         # line_ops = compute_score(ops)
    #         # total_ops += line_ops
    #         # total_score += line_score

    # op_count = total_ops['d'] + total_ops['s'] + total_ops['i']
    # ref_len = total_ops['d'] + total_ops['s'] + total_ops['e']
    # error_rate = (op_count / ref_len) * 100
    # # error_rate = (op_count) / sum(total_ops.values())*100

    # if args.n2d_mapping:
    #     print('%{} {:.2f} [ {} / {}, {} ins, {} del, {} sub ] {}'.format('FLEXWER',
    #                                                                      error_rate,
    #                                                                      op_count,
    #                                                                      ref_len,
    #                                                                      total_ops['i'],
    #                                                                      total_ops['d'],
    #                                                                      total_ops['s'],
    #                                                                      args.hyp
    #                                                                      ))

    # else:
    #     print('%{} {:.2f} [ {} / {}, {} ins, {} del, {} sub ] {}'.format('FLEXWER',
    #                                                                      error_rate,
    #                                                                      op_count,
    #                                                                      ref_len,
    #                                                                      total_ops['i'],
    #                                                                      total_ops['d'],
    #                                                                      total_ops['s'],
    #                                                                      args.hyp
    #                                                                      ))

    # if args.n2d_mapping:
    #     print('%{} {:.2f} [ {} / {}, {} ins, {} del, {} sub ] {}'.format('FLEXWER',
    #                                                                     error_rate,
    #                                                                     op_count,
    #                                                                     sum(total_ops.values(
    #                                                                     )),
    #                                                                     total_ops['i'],
    #                                                                     total_ops['d'],
    #                                                                     total_ops['s'],
    #                                                                     args.hyp
    #                                                                     ))

    # else:
    #     print('%{} {:.2f} [ {} / {}, {} ins, {} del, {} sub ] {}'.format('FLEXWER',
    #                                                                      error_rate,
    #                                                                      op_count,
    #                                                                      sum(total_ops.values(
    #                                                                      )),
    #                                                                      total_ops['i'],
    #                                                                      total_ops['d'],
    #                                                                      total_ops['s'],
    #                                                                      args.hyp
    #                                                                      ))


# import sys
# import re
# from pathlib import Path
# from collections import OrderedDict
# import matplotlib.pyplot as plt
# import matplotlib.patches as mpatches
# from matplotlib.collections import PatchCollection
# import numpy as np


# sys_dir = sys.argv[1]
# outfig = sys.argv[2]


# def read_ops(file):
#     ops = []
#     with open(str(file), 'r', encoding='utf8') as f:
#         for line in f:
#             op, ref, hyp, c = line.split()
#             ops.append((op, ref, hyp, c))
#     return ops


# def plot2(d):

#     f, ax = plt.subplots(1, 2)
#     # fig, ax = plt.subplots()
#     ax[0].set_aspect('equal')

#     pieLabels = [
#         'Ins',
#         'Del (OOV)',
#         'Del (in)',
#         'Sub (OOV)',
#         'Sub (in)'
#     ]

#     pieValues = d.values()

#     wedges, texts = ax[0].pie(
#         pieValues,
#         labels=pieLabels
#     )

#     groups = [[0], [1, 2], [3, 4]]
#     radfraction = 0.15
#     patches = []
#     for i in groups:
#         ang = np.deg2rad((wedges[i[-1]].theta2 + wedges[i[0]].theta1)/2,)
#         for j in i:
#             we = wedges[j]
#             center = (radfraction*we.r*np.cos(ang),
#                       radfraction*we.r*np.sin(ang))
#             patches.append(mpatches.Wedge(center, we.r, we.theta1, we.theta2))

#     colors = np.linspace(0, 1, len(patches))
#     collection = PatchCollection(patches, cmap=plt.cm.hsv)
#     collection.set_array(np.array(colors))
#     ax[1].add_collection(collection)
#     ax[1].autoscale(True)

#     # fig.tight_layout()
#     plt.savefig(outfig, dpi=300, format=None)


# def plot(d):

#     # The slice names of a population distribution pie chart

#     # pieLabels = d.keys()
#     pieLabels = [
#         'Ins',
#         'Del (OOV)',
#         'Del (in)',
#         'Sub (OOV)',
#         'Sub (in)'
#     ]

#     pieValues = d.values()

#     fig, ax = plt.subplots()

#     # add colors
#     # colors = ['#9F71C9', '#49E1B9', '#51A9C7', '#E8CD8F', '#F99AAE']
#     # colors = ['#E26882', '#EDC363', '#5EC3E5', '#47E0B7', '#A273CE']

#     colors = ['#ffcd38', '#38f8ff', '#38f8ff', '#ff3898', '#ff3898']

#     # explsion
#     explode = (0.05, 0.05, 0.05, 0.05, 0.05)

#     # Draw the pie chart
#     chart = ax.pie(
#         pieValues,
#         colors=colors,
#         labels=pieLabels,
#         explode=explode,
#         #    autopct='%1.2f',
#         autopct='%1.1f%%',
#         startangle=90,
#         # pctdistance=0.85
#     )

#     #
#     # for w in wedges:
#     #     w.set_linewidth(1)
#     #     w.set_edgecolor('black')

#     # fill slices
#     # patches = wedges[0]
#     chart[0][1].set_hatch('/')
#     chart[0][3].set_hatch('/')

#     # Aspect ratio - equal means pie is a circle
#     ax.axis('equal')

#     fig.tight_layout()
#     plt.savefig(outfig, dpi=300, format=None)


# if __name__ == "__main__":

#     lex = read_lexicon(lex_file)
#     print()
#     print('Size of lexicon:', len(lex))
#     print()
#     ops = read_ops(ops_file)

#     errors = OrderedDict()

#     categories = [
#         'ins',
#         'OOV_del',
#         'INV_del',
#         'OOV_sub',
#         'INV_sub',
#         # 'OVV_cor',
#         # 'INV_cor'
#     ]

#     for i in categories:
#         errors[i] = 0

#     for op, ref, hyp, c in ops:
#         if op == 'deletion':
#             if not ref in lex:
#                 errors['OOV_del'] += 1
#             else:
#                 errors['INV_del'] += 1

#         elif op == 'insertion':
#             errors['ins'] += 1

#         elif op == 'substitution':
#             if not ref in lex:
#                 errors['OOV_sub'] += 1
#             else:
#                 errors['INV_sub'] += 1

#         # elif op == 'correct':
#         #     if not ref in lex:
#         #         errors['OOV_cor'] += 1
#         #     else:
#         #         errors['INV_cor'] += 1

#     print('Errors:')
#     print()
#     for e in errors:
#         print('\t{}\t{}'.format(e, errors[e]))
#     # print(errors)
#     print()

#     plot(errors)
