#!/bin/bash

# Copyright 2012  Johns Hopkins University (author: Daniel Povey)  Tony Robinson
#           2017  Hainan Xu
#           2017  Ke Li

# rnnlm/train_rnnlm.sh: best iteration (out of 80) was 79, linking it to final iteration.
# rnnlm/train_rnnlm.sh: train/dev perplexity was 44.3 / 49.9. 
# Train objf: -1038.00 -5.35 -5.04 -4.87 -4.76 -4.68 -4.61 -4.56 -4.52 -4.47 -4.44 -4.41 -4.37 -4.35 -4.33 -4.31 -4.29 -4.27 -4.25 -4.24 -4.23 -4.21 -4.19 -4.17 -4.16 -4.15 -4.13 -4.12 -4.11 -4.10 -4.09 -4.07 -4.07 -4.06 -4.05 -4.04 -4.03 -4.02 -4.01 -4.00 -3.99 -3.98 -3.98 -3.97 -3.96 -3.96 -3.95 -3.94 -3.93 -3.93 -3.92 -3.92 -3.91 -3.91 -3.90 -3.90 -3.89 -3.88 -3.88 -3.88 -3.88 -3.88 -3.86 -3.86 -3.85 -3.85 -3.84 -3.83 -3.83 -3.83 -3.82 -3.82 -3.81 -3.81 -3.80 -3.80 -3.79 -3.79 -3.79 -3.79 
# Dev objf:   -11.73 -5.66 -5.18 -4.96 -4.82 -4.73 -4.66 -4.59 -4.54 -4.51 -4.47 -4.44 -4.40 -4.38 -4.36 -4.34 -4.32 -4.30 -4.28 -4.27 -4.26 -4.21 -4.19 -4.18 -4.16 -4.15 -4.14 -4.13 -4.12 -4.12 -4.11 -4.09 -4.09 -4.08 -4.07 -4.07 -4.06 -4.06 -4.05 -4.04 -4.04 -4.04 -4.03 -4.02 -4.02 -4.01 -4.01 -4.00 -4.00 -4.00 -3.99 -3.99 -3.98 -3.98 -3.98 -3.98 -3.97 -3.97 -3.97 -3.97 -3.96 -3.95 -3.95 -3.94 -3.94 -3.94 -3.94 -3.93 -3.93 -3.93 -3.93 -3.93 -3.93 -3.92 -3.92 -3.92 -3.92 -3.92 -3.91 -3.91 

# WER numbers

# without RNNLM
# %WER 7.51 [ 618 / 8234, 82 ins, 112 del, 424 sub ] exp/chain/tdnn_lstm1b_sp/decode_looped_tgpr_dev93/wer_10_1.0
# %WER 5.21 [ 294 / 5643, 55 ins, 34 del, 205 sub ] exp/chain/tdnn_lstm1b_sp/decode_looped_tgpr_eval92/wer_11_0.5

# with RNNLM
# %WER 5.74 [ 473 / 8234, 81 ins, 76 del, 316 sub ] exp/chain/tdnn_lstm1b_sp/decode_looped_tgpr_dev93_rnnlm/wer_14_1.0
# %WER 4.27 [ 241 / 5643, 62 ins, 23 del, 156 sub ] exp/chain/tdnn_lstm1b_sp/decode_looped_tgpr_eval92_rnnlm/wer_12_1.0


# Adapted for ARCHIMOB by Tannon Kew, Dec 2019

#########
## Inputs
#########

inp_text=$1 # train_orig_utt.txt
lexicon=$2 # lexiconp.txt
text_dir=$3 # output text dir (gets created) --> orig/rnnlm_rescore/text
out_dir=$4 # orig/rnnlm_rescore/model or orig/rnnlm_rescore/out

# # for rescoring
# oldlang=$5


#########
## Config
#########
# for testing:
prep_train_dir=1
prep_config_dir=1
prep_rnnlm_dir=1
train_rnnlm=1


# dir=exp/rnnlm_lstm_tdnn_1b
use_gpu=false
embedding_dim=128 # 800
lstm_rpd=64 # 200
lstm_nrpd=64 # 200
embedding_l2=0.001 # embedding layer l2 regularize
comp_l2=0.001 # component-level l2 regularize
output_l2=0.001 # output-layer l2 regularize
epochs=15 # 20
stage=-10
train_stage=-10

# variables for rnnlm rescoring
# ac_model_dir=exp/chain/tdnn_lstm1b_sp
# ngram_order=4
# decode_dir_suffix=rnnlm

. ./cmd.sh
. ./utils/parse_options.sh
[ -z "$cmd" ] && cmd=$train_cmd


# text=data/local/dict_nosp_larger/cleaned.gz
# wordlist=data/lang_nosp/words.txt
# text_dir=data/rnnlm/text_nosp
mkdir -p $out_dir/config

START_TIME=$(date +%s) # record time of operations

set -e

###############################################

for f in $inp_text $lexicon; do
  [ ! -f $f ] && \
    echo "$0: expected file $f to exist; Check input args." && exit 1
done

###################
## Prepare Text dir
###################

if [[ $stage -le 0 && $prep_train_dir -ne 0 ]]; then

  echo ""
  echo "######################################"
  echo "### BEGIN: PREPARING TRAINING DATA ###"
  echo "######################################"
  echo ""

  mkdir -p $text_dir
  echo -n >$text_dir/dev.txt
  # hold out one in every 500 lines as dev data.
  cat $inp_text  | awk -v text_dir=$text_dir '{if(NR%50 == 0) { print >text_dir"/dev.txt"; } else {print;}}' >$text_dir/train.txt

fi

if [[ $stage -le 1 && $prep_config_dir -ne 0 ]]; then

  echo ""
  echo "####################################"
  echo "### BEGIN: PREPARING CONFIG DATA ###"
  echo "####################################"
  echo ""

  # the training scripts require that <s>, </s> and <brk> be present in a particular
  # order.
  awk '{print $1}' $lexicon | sort | uniq | \
    awk 'BEGIN{print "<eps> 0";print "<s> 1"; print "</s> 2"; print "<brk> 3";n=4;} {print $1, n++}' \
        >$out_dir/config/words.txt
  # words that are not present in words.txt but are in the training or dev data, will be
  # mapped to <SPOKEN_NOISE> during training.
  echo "<SPOKEN_NOISE>" >$out_dir/config/oov.txt

#   # the training scripts require that <s>, </s> and <brk> be present in a particular
#   # order.
#   cp $wordlist $dir/config/ 
#   n=`cat $dir/config/words.txt | wc -l` 
#   echo "<brk> $n" >> $dir/config/words.txt 

#   # words that are not present in words.txt but are in the training or dev data, will be
#   # mapped to <SPOKEN_NOISE> during training.
#   echo "<SPOKEN_NOISE>" >$dir/config/oov.txt

  cat > $out_dir/config/data_weights.txt <<EOF
train   1   1.0
EOF
  
  echo ""
  echo "################################"
  echo "### BEGIN: GET UNIGRAM PROBS ###"
  echo "################################"
  echo ""

  rnnlm/get_unigram_probs.py --vocab-file=$out_dir/config/words.txt \
                             --unk-word="<SPOKEN_NOISE>" \
                             --data-weights-file=$out_dir/config/data_weights.txt \
                             $text_dir | awk 'NF==2' >$out_dir/config/unigram_probs.txt

  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/get_unigram_probs.py\n" && exit 1

  echo ""
  echo "##############################"
  echo "### BEGIN: CHOOSE FEATURES ###"
  echo "##############################"
  echo ""

  # choose features
  rnnlm/choose_features_2.py --unigram-probs=$out_dir/config/unigram_probs.txt \
                           --use-constant-feature=true \
                           --min-ngram-order=1 \
                           --max-ngram-order=4 \
                           --top-word-features=1000 \
                           --min-frequency 1.0e-06 \
                           --special-words='<s>,</s>,<brk>,<SPOKEN_NOISE>' \
                           $out_dir/config/words.txt > $out_dir/config/features.txt

  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/choose_features_2.py\n" && exit 1

lstm_opts="l2-regularize=$comp_l2"
tdnn_opts="l2-regularize=$comp_l2"
output_opts="l2-regularize=$output_l2"

  cat >$out_dir/config/xconfig <<EOF
input dim=$embedding_dim name=input
relu-renorm-layer name=tdnn1 dim=$embedding_dim $tdnn_opts input=Append(0, IfDefined(-1)) 
fast-lstmp-layer name=lstm1 cell-dim=$embedding_dim recurrent-projection-dim=$lstm_rpd non-recurrent-projection-dim=$lstm_nrpd $lstm_opts
relu-renorm-layer name=tdnn2 dim=$embedding_dim $tdnn_opts input=Append(0, IfDefined(-2))
fast-lstmp-layer name=lstm2 cell-dim=$embedding_dim recurrent-projection-dim=$lstm_rpd non-recurrent-projection-dim=$lstm_nrpd $lstm_opts
relu-renorm-layer name=tdnn3 dim=$embedding_dim $tdnn_opts input=Append(0, IfDefined(-1))
output-layer name=output $output_opts include-log-softmax=false dim=$embedding_dim
EOF
  
  rnnlm/validate_config_dir.sh $text_dir $out_dir/config

fi

if [[ $stage -le 2 && $prep_rnnlm_dir -ne 0 ]]; then
  
  echo ""
  echo "##################################"
  echo "### BEGIN: PREPARING RNNLM DIR ###"
  echo "##################################"
  echo ""

  # the --unigram-factor option is set larger than the default (100)
  # in order to reduce the size of the sampling LM, because rnnlm-get-egs
  # was taking up too much CPU (as much as 10 cores).
  rnnlm/prepare_rnnlm_dir.sh --unigram-factor 200.0 \
                             $text_dir $out_dir/config $out_dir
  
  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/prepare_rnnlm_dir.sh\n" && exit 1
  
  CUR_TIME=$(date +%s)
  echo ""
  echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
  echo ""

fi

if [[ $stage -le 3 && $train_rnnlm -ne 0 ]]; then

  echo ""
  echo "#############################"
  echo "### BEGIN: TRAINING RNNLM ###"
  echo "#############################"
  echo ""

  rnnlm/train_rnnlm.sh --use_gpu $use_gpu --num-jobs-initial 1 --num-jobs-final 3 \
                       --embedding_l2 $embedding_l2 \
                       --stage $train_stage --num-epochs $epochs --cmd "$cmd" $out_dir

  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/train_rnnlm.sh\n" && exit 1

fi

# if [ $stage -le 4 ]; then
#     # Lattice rescoring
#     rnnlm/lmrescore_pruned.sh \
#       --cmd "$decode_cmd --mem 4G" \
#       --weight 0.8 --max-ngram-order $ngram_order \
#       data/lang_test_$LM $dir \
#       data/test_${decode_set}_hires ${decode_dir} \
#       ${decode_dir}_${decode_dir_suffix} &
#   done
#   wait
# fi

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

echo ""
echo "### DONE: $0 ###"
echo ""

exit 0