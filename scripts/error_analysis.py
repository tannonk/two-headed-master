#!/usr/bin/python3
#! -*- coding: utf-8 -*-

import sys
import re
from pathlib import Path
from collections import OrderedDict
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import numpy as np

sys_dir = sys.argv[1]
outfig = sys.argv[2]

lex_file = Path(sys_dir) / Path('lw_out/tmp/lexicon/lexicon.txt')
ops_file = Path(sys_dir) / \
    Path('eval_out/decode/scoring_kaldi/wer_details/ops')


def read_lexicon(file):
    lex = set()
    with open(str(file), 'r', encoding='utf8') as f:
        for line in f:
            line = line.split()
            lex.add(line[0].strip())
    return lex


def read_ops(file):
    ops = []
    with open(str(file), 'r', encoding='utf8') as f:
        for line in f:
            op, ref, hyp, c = line.split()
            ops.append((op, ref, hyp, c))
    return ops


def plot2(d):

    f, ax = plt.subplots(1, 2)
    # fig, ax = plt.subplots()
    ax[0].set_aspect('equal')

    pieLabels = [
        'Ins',
        'Del (OOV)',
        'Del (in)',
        'Sub (OOV)',
        'Sub (in)'
    ]

    pieValues = d.values()

    wedges, texts = ax[0].pie(
        pieValues,
        labels=pieLabels
    )

    groups = [[0], [1, 2], [3, 4]]
    radfraction = 0.15
    patches = []
    for i in groups:
        ang = np.deg2rad((wedges[i[-1]].theta2 + wedges[i[0]].theta1)/2,)
        for j in i:
            we = wedges[j]
            center = (radfraction*we.r*np.cos(ang),
                      radfraction*we.r*np.sin(ang))
            patches.append(mpatches.Wedge(center, we.r, we.theta1, we.theta2))

    colors = np.linspace(0, 1, len(patches))
    collection = PatchCollection(patches, cmap=plt.cm.hsv)
    collection.set_array(np.array(colors))
    ax[1].add_collection(collection)
    ax[1].autoscale(True)

    # fig.tight_layout()
    plt.savefig(outfig, dpi=300, format=None)


def plot(d):

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
    explode = (0.05, 0.05, 0.05, 0.05, 0.05)

    # Draw the pie chart
    chart = ax.pie(
        pieValues,
        colors=colors,
        labels=pieLabels,
        explode=explode,
        #    autopct='%1.2f',
        autopct='%1.1f%%',
        startangle=90,
        # pctdistance=0.85
    )

    #
    # for w in wedges:
    #     w.set_linewidth(1)
    #     w.set_edgecolor('black')

    # fill slices
    # patches = wedges[0]
    chart[0][1].set_hatch('/')
    chart[0][3].set_hatch('/')

    # Aspect ratio - equal means pie is a circle
    ax.axis('equal')

    fig.tight_layout()
    plt.savefig(outfig, dpi=300, format=None)


if __name__ == "__main__":

    lex = read_lexicon(lex_file)
    print()
    print('Size of lexicon:', len(lex))
    print()
    ops = read_ops(ops_file)

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

    for op, ref, hyp, c in ops:
        if op == 'deletion':
            if not ref in lex:
                errors['OOV_del'] += int(c)
            else:
                errors['INV_del'] += int(c)

        elif op == 'insertion':
            errors['ins'] += int(c)

        elif op == 'substitution':
            if not ref in lex:
                errors['OOV_sub'] += int(c)
            else:
                errors['INV_sub'] += int(c)

        # elif op == 'correct':
        #     if not ref in lex:
        #         errors['OOV_cor'] += int(c)
        #     else:
        #         errors['INV_cor'] += int(c)

    print('Errors:')
    print()
    for e in errors:
        print('\t{}\t{}'.format(e, errors[e]))
    # print(errors)
    print()

    plot(errors)
