#!/bin/bash

# set -v
set -x
set -e

## Eample call:

## nohup bash /home/tannon/my_scripts/stat_lm_comparison.sh /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt /mnt/tannon/corpus_data/csv_files/test_files/test_orig_utt.txt /mnt/tannon/processed/archimob_r2/orig/am_out/initial_data/tmp/vocabulary.txt /mnt/tannon/lms/stat_ngram_exp/orig > /mnt/tannon/lms/stat_ngram_exp/orig/stat_ngram_exp_log.txt&

## nohup bash /home/tannon/my_scripts/stat_lm_comparison.sh /mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_norm_utt.txt /mnt/tannon/corpus_data/csv_files/test_files/test_norm_utt.txt /mnt/tannon/processed/archimob_r2/norm/am_out/initial_data/tmp/vocabulary.txt /mnt/tannon/lms/stat_ngram_exp/norm > /mnt/tannon/lms/stat_ngram_exp/norm/stat_ngram_exp_log.txt&

## to parse the output log file, call python3 /home/tannon/my_scripts/parse_lm_stats.py /mnt/tannon/lms/stat_ngram_exp/orig/stat_ngram_exp_log.txt > /mnt/tannon/lms/stat_ngram_exp/orig/parsed_log_results.tsv 

##############
## Input files
##############
train_file=$1   # e.g. /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt
dev_file=$2     # e.g. /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt
test_file=$3    # e.g. /mnt/tannon/corpus_data/csv_files/test_files/test_orig_utt.txt
vocab_file=$4   # e.g. /mnt/tannon/processed/archimob_r2/orig/am_out/initial_data/tmp/vocabulary.txt
output_dir=$5   # e.g. /mnt/tannon/lms/stat_ngram_exp/orig/

#########
## Config
#########
do_mitlm=1
do_srilm=1
# do_rnnlm=0
# do_ml_smoothing=1
do_wb_smoothing=1
do_mkn_smoothing=1
do_ukn_smoothing=1
min_n=1
max_n=6

echo $0 $@

if [[ $# -lt 4 ]]; then
    echo "Wrong call. Should be: $0 train_file dev_file test_file output_dir"
    exit 1
fi

# Check whether MITLM is installed:
type estimate-ngram &> /dev/null
[[ $? -ne 0 ]] && echo "Error: the MIT toolkit is not installed" && exit 1

# Check whether SRILM is installed:
type ngram &> /dev/null
[[ $? -ne 0 ]] && echo "Error: the SRILM toolkit is not installed or not in $PATH" && exit 1

for f in $train_file $dev_file $test_file $vocab_file; do
    [[ ! -e $f ]] && echo "Error: missing file $f" && exit 1
done

mkdir -p $output_dir

####################
## Intermediate dirs
####################
mitlm_dir="$output_dir/mitlm"
srilm_dir="$output_dir/srilm"
rnnlm_dir="$output_dir/rnnlm"


###########################
# 1. experiments with mitlm
###########################

if [[ $do_mitlm -ne 0 ]]; then

  mkdir -p $mitlm_dir

  for (( n=$min_n; n <= $max_n; n++ ))
  do
    out_lm=$mitlm_dir/mitlm_mkn_${n}.arpa
    # echo -e "\nBuilding LM $out_lm with MITLM smoothing=$mitlm_smoothing\n"
    estimate-ngram -order $n \
        -text $train_file \
        -smoothing "ModKN" \
        -eval-perp $test_file \
        -write-lm $out_lm
  done

  for (( n=$min_n; n <= $max_n; n++ ))
  do
    out_lm=$mitlm_dir/mitlm_mkn_open_${n}.arpa
    estimate-ngram -order $n \
        -text $train_file \
        -vocab $vocab_file \
        -smoothing "ModKN" \
        -eval-perp $test_file \
        -unk "true" \
        -write-lm $out_lm
  done

  for (( n=$min_n; n <= $max_n; n++ ))
    do
      out_lm=$mitlm_dir/mitlm_mkn_tuned_${n}.arpa
      # echo -e "\nBuilding LM $out_lm with MITLM smoothing=$mitlm_smoothing\n"
      estimate-ngram -order $n \
          -text $train_file \
          -smoothing "ModKN" \
          -opt-perp $dev_file \
          -eval-perp $test_file \
          -write-lm $out_lm
    done

    for (( n=$min_n; n <= $max_n; n++ ))
    do
      out_lm=$mitlm_dir/mitlm_mkn_open_tuned_${n}.arpa
      # echo -e "\nBuilding LM $out_lm with MITLM smoothing=$mitlm_smoothing\n"
      estimate-ngram -order $n \
          -text $train_file \
          -vocab $vocab_file \
          -smoothing "ModKN" \
          -opt-perp $dev_file \
          -eval-perp $test_file \
          -unk "true" \
          -write-lm $out_lm
    done

fi

###########################
# 2. experiments with srilm
###########################

if [[ $do_srilm -ne 0 ]]; then

  mkdir -p $srilm_dir

  # if [[ $do_add1_smoothing -ne 0 ]]; then
  #   for (( n=$min_n; n <= $max_n; n++ ))
  #   do
  #     out_lm=$srilm_dir/add1_${n}.arpa
  #     ngram-count -text $train_file -order $n -addsmooth 1 -interpolate -lm $out_lm
  #     wait
  #     ngram -lm $out_lm -order $n -ppl $test_file
  #   done
  # fi

  # if [[ $do_gt_smoothing -ne 0 ]]; then
  #   # good turing smoothing
  #   for (( n=$min_n; n <= $max_n; n++ ))
  #   do
  #     out_lm=$srilm_dir/gt_${n}.arpa
  #     echo -e "\nBuilding LM $out_lm with SRILM smoothing = Good Turing\n"
  #     ngram-count -text $train_file \
  #         -order $n \
  #         -unk \
  #         -gt1min 3 -gt1max 7 \
  #         -gt2min 3 -gt2max 7 \
  #         -gt3min 3 -gt3max 7 \
  #         -gt4min 3 -gt2max 7 \
  #         -gt5min 3 -gt3max 7 \
  #         -lm $out_lm
  #   done
  #
  #   for (( n=$min_n; n <= $max_n; n++ ))
  #   do
  #     lang_model=$srilm_dir/gt_${n}.arpa
  #     echo -e "\nEvaluating perplexity for $lang_model on $test_file\n"
  #     ngram -lm $lang_model -order $n -ppl $test_file -unk
  #   done
  # fi


  #####################
  ## SRILM WB SMOOTHING
  #####################

    if [[ $do_wb_smoothing -ne 0 ]]; then
        
        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_wb_${n}.arpa
          ngram-count -text $train_file -order $n -wbdiscount -lm $out_lm
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done

        ## TRY INTERPOLATION:

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_wb_int_${n}.arpa
          ngram-count -text $train_file -order $n -wbdiscount -interpolate -lm $out_lm
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done

        ## TRY OPEN VOCAB (UNK):
        # Build an ``open vocabulary'' LM, i.e., one that contains the unknown-word token as a regular word. The default is to remove the unknown word.
        # J&M:
        # An open vocabulary system is one in
        # which we model these potential unknown words in the
        # test set by adding a pseudo-word called <UNK>

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_wb_open_${n}.arpa
          ngram-count -text $train_file -order $n -wbdiscount -lm $out_lm -unk
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done


        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_wb_int_open_${n}.arpa
          ngram-count -text $train_file -order $n -vocab $vocab_file -wbdiscount -interpolate -lm $out_lm -unk
          wait
          ngram -lm $out_lm -order $n -ppl $test_file -unk
        done

    fi

  #########################
  ## SRILM MOD KN SMOOTHING
  #########################

    if [[ $do_mkn_smoothing -ne 0 ]]; then
        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_mkn_${n}.arpa
          ngram-count -text $train_file -order $n -kndiscount -lm $out_lm
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done

        ## TRY INTERPOLATION:

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_mkn_int_${n}.arpa
          ngram-count -text $train_file -order $n -kndiscount -interpolate -lm $out_lm
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done

        ## TRY OPEN VOCAB (UNK):

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_mkn_open_${n}.arpa
          ngram-count -text $train_file -order $n -vocab $vocab_file -kndiscount -lm $out_lm -unk
          wait
          ngram -lm $out_lm -order $n -ppl $test_file -unk
        done

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_mkn_int_open_${n}.arpa
          ngram-count -text $train_file -order $n -vocab $vocab_file -kndiscount -interpolate -lm $out_lm -unk
          wait
          ngram -lm $out_lm -order $n -ppl $test_file -unk
        done

    fi
    
    if [[ $do_ukn_smoothing -ne 0 ]]; then
        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_ukn_${n}.arpa
          ngram-count -text $train_file -order $n -ukndiscount -lm $out_lm
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done

        ## TRY INTERPOLATION:

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_ukn_int_${n}.arpa
          ngram-count -text $train_file -order $n -ukndiscount -interpolate -lm $out_lm
          wait
          ngram -lm $out_lm -order $n -ppl $test_file
        done

        ## TRY OPEN VOCAB (UNK):

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_ukn_open_${n}.arpa
          ngram-count -text $train_file -order $n -vocab $vocab_file -ukndiscount -lm $out_lm -unk
          wait
          ngram -lm $out_lm -order $n -ppl $test_file -unk
        done

        for (( n=$min_n; n <= $max_n; n++ ))
        do
          out_lm=$srilm_dir/srilm_ukn_int_open_${n}.arpa
          ngram-count -text $train_file -order $n -vocab $vocab_file -ukndiscount -interpolate -lm $out_lm -unk
          wait
          ngram -lm $out_lm -order $n -ppl $test_file -unk
        done
      
    fi

fi



###########################
# 3. experiments with rnnlm
###########################





echo "### Done: $0 ###"
