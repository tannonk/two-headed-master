#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
from pathlib import Path
from operator import itemgetter
import re

decode_dir = Path(sys.argv[1])

wer_files = [f for f in decode_dir.iterdir() if f.stem.startswith('wer_')]

wer_score = re.compile(r'%WER\s+(\d+\.\d+)')

collected_wer_scores = []

for file in wer_files:
    _, lmwt, wip = file.name.split('_')
    with open(str(file), 'r', encoding='utf8') as f:
        best_wer = re.search(wer_score, f.read()).group(1)
        collected_wer_scores.append((float(best_wer), int(lmwt), float(wip)))

collected_wer_scores = sorted(collected_wer_scores,key=itemgetter(0))

print(collected_wer_scores)

# for i in collected_wer_scores:
#     print(i[0], '\t', i[1], '\t', i[2])


if sys.argv[2]:
    try:
        import pandas as pd
        import matplotlib.pyplot as plt
        from mpl_toolkits.mplot3d import Axes3D

        df = pd.DataFrame(collected_wer_scores, columns=['WER', 'LMWT', 'WIP'])

        fig = plt.figure()
        ax = fig.add_subplot(111, projection='3d')
        ax.plot(df['LMWT'], df['WIP'], df['WER'])

        plt.savefig(sys.argv[2], dpi=300, format='png')

        print('Finished.')

    except ImportError:
        print('Failed to import data analysis modules. Make sure pandas and matplotlib are installed.')
        sys.exit(1)
