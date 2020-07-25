#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Requires LXML. First activate conda and activate environment with lxml installed

    conda activate
    source activate py37

Example call:
    python3 /home/tannon/my_scripts/create_norm2dieth_dictionary.py /mnt/data/archimob_r2/xml/ norm2dieth.json
"""

import sys
import re
from pathlib import Path
from collections import defaultdict
import json
from lxml import etree

norm_to_dieth_map = defaultdict(set)


def clean_word(w):
    w = re.sub(r'\)\(', '', w)
    return w


for file in Path(sys.argv[1]).iterdir():
    if file.suffix == '.xml':
        tree = etree.parse(str(file))
        ns = tree.getroot().nsmap[None]
        # for utt in tree.getroot().iter("{"+ns+"}u"):
        for word in tree.getroot().iter("{"+ns+"}w"):
            norm = word.get('normalised')

            # glue multi-token normalised forms together
            norm = re.sub(r'\s+', '_', norm)

            if not norm or norm == '==' or norm.endswith('***'):
                continue
            else:
                word_form = clean_word(word.text)

                if word_form and not '***' in word_form:
                    norm_to_dieth_map[norm].add(word_form)

print('{} normalised types found.'.format(len(norm_to_dieth_map)))
dieth_forms = sum([len(v) for v in norm_to_dieth_map.values()])
print('{} dieth forms found.'.format(dieth_forms))

# convert set to list to write out as JSON
json_compatible_dict = {}
for k, v in norm_to_dieth_map.items():
    json_compatible_dict[k] = sorted(list(v))  # sort for consistency

with open(sys.argv[2], 'w', encoding='utf8') as outf:
    json.dump(json_compatible_dict, outf, indent=4,
              ensure_ascii=False, sort_keys=True)

# pp.pprint(dict(norm_to_dieth_map))

# pretty printing to python file
# print('#!/usr/bin/python3')
# print('# -*- coding: utf-8 -*-')
# print()
# print('n2d_map = {')
# for k in sorted(norm_to_dieth_map.keys()):
#     print('\t"'+k+'": {')
#     for v in norm_to_dieth_map[k]:
#         print('\t\t"'+v+'",')
#     print('\t\t},')
# print('\t}')
# print()
# print("if __name__ == '__main__':")
# print('\tpass')
