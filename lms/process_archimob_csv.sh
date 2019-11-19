#!/bin/bash

set -e
set -u

echo $0 $@

#############
## Input args
#############
csv_file=$1

# script_dir=/home/tannon/my_scripts
# clusters=/home/tannon/kaldi_wrk/two-headed-master/manual/clusters.txt
# n2d_map=/mnt/tannon/corpus_data/norm2dieth.json
# sampa=/mnt/tannon/corpus_data/SAMPA

for f in $csv_file; do
    [[ ! -e $f ]] && echo -e "\n\tERROR: missing $f\n" && exit 1
done

xpath=${csv_file%/*} # cut the file path
xbase=${csv_file##*/} # cut the file name with extension
# xfext=${xbase##*.} # cut the extension
xpref=${xbase%.*} # cut the file name without extension

# echo $xpath
# echo $xbase
# echo $xfext
# echo $xpref

# step 1: extract utterances
echo "Extacting utterances..."
cut -d, -f2 ${csv_file} | \
sed '1d' | \
perl -pe ' s#/##g; s#(\s)+#\1#g; s#^\s+##; ' \
> ${xpath}/${xpref}_orig_utt.txt

cut -d, -f3 ${csv_file} | \
sed '1d' | \
perl -pe ' s#/##g; s#(\s)+#\1#g; s#^\s+##; ' \
> ${xpath}/${xpref}_norm_utt.txt

# step 2: extract vocab
echo "Extacting vocabularies..."
cut -d, -f2 ${csv_file} | sed '1d' | \
perl -pe 's#\s+#\n#g' | grep -v -P '^$|<' | sort -u > ${xpath}/${xpref}_orig_vocab.txt

cut -d, -f3 ${csv_file} | sed '1d' | \
perl -pe 's#\s+#\n#g' | grep -v -P '^$|<' | sort -u > ${xpath}/${xpref}_norm_vocab.txt


## Outdated scripts
# # step 3: create norm lexicon from Dieth transcriptions
# echo "Creating normalised lexicon..."
# python3 ${script_dir}/create_dieth_normalised_lexicon.py \
# -v ${csv_dir}/norm_vocabulary.txt \
# -c ${clusters} \
# --n2d ${n2d_map} \
# -o ${csv_dir}/norm_dieth_lexicon.txt \
# --verbose
#
# # step 4: create norm lexicon from SAMPA annotations
# echo "Creating normalised lexicon with SAMPA annotations..."
# python3 ${script_dir}/create_sampa_normalised_lexicon.py \
# -s ${sampa}/*_small.csv \
# -v ${csv_dir}/norm_vocabulary.txt \
# -o ${csv_dir}/norm_sampa_lexicon.txt

echo "Finished $0"
