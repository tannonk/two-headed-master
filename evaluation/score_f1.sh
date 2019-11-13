#!/bin/bash

## To call:
## bash score_f1.sh <decode directory> <norm2dieth mapping file>
## e.g. bash ./score_f1.sh /mnt/tannon/processed/archimob_r1/orig/decode_out/decode /mnt/tannon/corpus_data/norm2dieth.json

set -e

decode_dir=$1
n2d_mapping=$2
scoring_dir=$decode_dir/scoring_kaldi
word_ins_penalty=0.0,0.5,1.0
min_lmwt=7
max_lmwt=17

# decode/scoring_kaldi/penalty_0.5/7.txt

echo "$0 $@"  # Print the command line for logging

py_version=$(python3 -V 2>&1 | grep -Po '(?<=Python )(.+)')
if [[ ! "$py_version" =~ ^3.7* ]]; then
  echo -e "ERROR: Activate conda with 'conda activate' before running!\nCurrent python version is $py_version :(" && exit 1
fi

for wip in $(echo $word_ins_penalty | sed 's/,/ /g'); do
  for lmwt in $(seq $min_lmwt $max_lmwt); do
    hyp_file="$scoring_dir/penalty_$wip/$lmwt.txt"
    output_file="$decode_dir/f1_${lmwt}_${wip}"
    [ ! -f $hyp_file ] && echo -e "ERROR: Missing file $hyp_file" && exit 1;
    echo "Scoring $hyp_file..."
    python3 scherrer_eval.py \
    --ref $scoring_dir/test_filt.txt \
    --hyp $hyp_file \
    -d $n2d_mapping \
    > $output_file
  done
done
