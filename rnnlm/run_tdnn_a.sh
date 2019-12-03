#!/bin/bash

# set -e

# Copyright 2012  Johns Hopkins University (author: Daniel Povey)  Tony Robinson
#           2015  Guoguo Chen

# Adapted by Tannon Kew, Nov 2019

# This script is an adaption of run_tdnn_a from Kaldi's WSJ
# example. This script trains prepares directories required
# for training RNNLM and trains a TDNN using rnnlm-train in Kaldi.

#########
## Inputs
#########

inp_text=$1 # train_orig_utt.txt
lexicon=$2 # lexiconp.txt
text_dir=$3 # output text dir (gets created) --> orig/rnnlm_rescore/text
out_dir=$4 # orig/rnnlm_rescore/model or orig/rnnlm_rescore/out

#########
## Config
#########
# for testing:
prep_train_dir=1
prep_config_dir=1
prep_rnnlm_dir=1
train_rnnlm=1

# adapted configuration section.
cmd=uzh/run.pl
use_gpu=false

# default configuration settings
embedding_dim=600
stage=0
train_stage=0


# This call selects the tool used for parallel computing: ($train_cmd)
# . cmd.sh

. utils/parse_options.sh

echo $0 $@
if [[ $# -lt 4 ]]; then
    echo ""
    echo "Wrong call. Should be: $0 text lexicon output_dir"
    echo "PA 1: training utterances for RNNLM"
    echo -e "\te.g. csv_files/archimob_r2/train_orig_utt.txt"
    echo "PA 2: lexicon.txt or lexiconp.txt used for training acoustic models"
    echo -e "\te.g. am_out/initial_data/ling/lexiconp.txt"
    echo "PA 3: RNNLM training text data directory (will be created)"
    echo "PA 4: RNNLM output data directory (will be created)"
    echo ""
    exit 1
fi

START_TIME=$(date +%s) # record time of operations

mkdir -p $out_dir/config

for f in $inp_text $lexicon; do
  [ ! -f $f ] && \
    echo "$0: ERROR: Missing $f; Check your input arguments." && exit 1
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
  # hold out one in every 50 lines as dev data.
  cat $inp_text | awk -v text_dir=$text_dir '{if(NR%50 == 0) { print >text_dir"/dev.txt"; } else {print;}}' > $text_dir/train.txt
  
  rnnlm/ensure_counts_present.sh $text_dir

  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/ensure_counts_present.sh\n" && exit 1

  # python3 rnnlm/validate_text_dir.py --spot-check=true $text_dir

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

  cat > $out_dir/config/data_weights.txt <<EOF
train   1   1.0
EOF

  # create file required for lattice-lmrescore-kaldi-rnnlm
  # in lmrescore.sh /out/special_symbol_opts.txt
  rnnlm/get_special_symbol_opts_2.py < $out_dir/config/words.txt > $out_dir/special_symbol_opts.txt
  
  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/get_special_symbol_opts.py\n" && exit 1
  
  echo ""
  echo "################################"
  echo "### BEGIN: GET UNIGRAM PROBS ###"
  echo "################################"
  echo ""

  rnnlm/get_unigram_probs.py --vocab-file=$out_dir/config/words.txt \
                             --unk-word="<SPOKEN_NOISE>" \
                             --data-weights-file=$out_dir/config/data_weights.txt \
                             $text_dir > $out_dir/config/unigram_probs.txt

  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/get_unigram_probs.py\n" && exit 1

  echo ""
  echo "##############################"
  echo "### BEGIN: CHOOSE FEATURES ###"
  echo "##############################"
  echo ""


  ### choose features
  rnnlm/choose_features_2.py --unigram-probs=$out_dir/config/unigram_probs.txt \
                           --use-constant-feature=true \
                           --special-words='<s>,</s>,<brk>,<SPOKEN_NOISE>' \
                           $out_dir/config/words.txt > $out_dir/config/features.txt

  [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/choose_features_2.py\n" && exit 1

#   cat > $out_dir/config/xconfig <<EOF
# input dim=$embedding_dim name=input
# relu-renorm-layer name=tdnn1 dim=$embedding_dim input=Append(0, IfDefined(-1))
# fast-lstmp-layer name=lstm1 cell-dim=$embedding_dim recurrent-projection-dim=$lstm_rpd non-recurrent-projection-dim=$lstm_nrpd
# relu-renorm-layer name=tdnn2 dim=$embedding_dim input=Append(0, IfDefined(-2))
# fast-lstmp-layer name=lstm2 cell-dim=$embedding_dim recurrent-projection-dim=$lstm_rpd non-recurrent-projection-dim=$lstm_nrpd
# relu-renorm-layer name=tdnn3 dim=$embedding_dim input=Append(0, IfDefined(-1))
# output-layer name=output include-log-softmax=false dim=$embedding_dim
# EOF

  cat >$out_dir/config/xconfig <<EOF
input dim=$embedding_dim name=input
relu-renorm-layer name=tdnn1 dim=600 input=Append(0, IfDefined(-1))
relu-renorm-layer name=tdnn2 dim=600 input=Append(0, IfDefined(-1))
relu-renorm-layer name=tdnn3 dim=600 input=Append(0, IfDefined(-2))
output-layer name=output include-log-softmax=false dim=$embedding_dim
EOF

  # rnnlm/validate_config_dir.sh $text_dir $out_dir/config

  # [[ $? -ne 0 ]] && echo -e "\n\tERROR: in rnnlm/validate_config_dir.sh\n" && exit 1
  
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
                  --stage $train_stage --num-epochs 10 --cmd $cmd $out_dir

fi

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

echo ""
echo "### DONE: $0 ###"
echo ""