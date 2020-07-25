#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Reads in changes to be made from JSON file and writes new XML files

**Note**
    requires lxml
        activate conda
        source activate py37

python3 add_archimob_corrections.py <change file> <input xml dir> <output xml dir>

Example call:

    python3 my_scripts/add_archimob_corrections.py \
    /home/tannon/corpus_data/updated_corrections_larissa_11_10_2019.json
    /mnt/data/archimob_r1/xml/ \
    /mnt/data/archimob_r1/xml_corrected/

    python3 my_scripts/add_archimob_corrections.py \
    /home/tannon/corpus_data/updated_corrections_larissa_11_10_2019.json \
    /mnt/data/archimob_r2/xml/ \
    /mnt/data/archimob_r2/xml_corrected/
"""

import sys
from pathlib import Path
import json
from lxml import etree

changes_file = sys.argv[1] # e.g. '/home/tannon/corpus_data/updated_corrections_larissa_11_10_2019.json'
in_xml_path = Path(sys.argv[2])
out_xml_path = Path(sys.argv[3])
xml_ns = 'http://www.w3.org/XML/1998/namespace'
ids = {}

# read in updated_corrections_larissa_11_10_2019.json as dictionary
with open(changes_file, 'r', encoding='utf8') as f:
    changes = json.loads(f.read())
    for item in changes:
        ids[item['id']] = item['changes']

# establish output directory in case doesn't exist
out_xml_path.mkdir(parents=True, exist_ok=True)

for infile in sorted(in_xml_path.iterdir()):
    if infile.suffix == '.xml':
        outfile = str(out_xml_path / infile.name)

        # for each input xml file, parse the xml tree
        tree = etree.parse(str(infile))
        ns = tree.getroot().nsmap[None]
        for w in tree.getroot().iter('{'+ns+'}w'):
            w_id = w.attrib.get('{'+xml_ns+'}id')
            # if the word id is specified in corretions dictionary make relevant changes
            if w_id in ids:
                if 'text' in ids[w_id]:
                    w.text = ids[w_id]['text']
                    print(f'made change {ids[w_id]} --> {w.text}')
                if 'normalised' in ids[w_id]:
                    w.attrib['normalised'] = ids[w_id]['normalised']
                    print(f'made change {ids[w_id]} --> {w.attrib["normalised"]}')

        # write the modified tree to the newly created output file
        with open(outfile, 'wb') as outf:
            outf.write(etree.tostring(tree, xml_declaration=True, pretty_print=True, encoding='UTF-8'))
