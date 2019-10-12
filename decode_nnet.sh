#!/bin/bash

set -u

#
# This script is an interface for steps/nnet2/decode.sh. Note that it is
# designed to process the features exactly in the same way followed during
# nnet2 (and nnet2 discriminative) training. Therefore, it does not support
# decoding with GMM models.
#

################
# Configuration:
################
num_jobs=4  # Number of jobs for parallel processing

#####################################
# Flags to choose with stages to run:
#####################################
do_feature_extraction=1
do_decoding=1

# This call selects the tool used for parallel computing: ($train_cmd)
. cmd.sh

# This includes in the path the kaldi binaries:
. path.sh

# This parses any input option, if supplied.
. utils/parse_options.sh

echo $0 $@
if [[ $# -ne 5 ]]; then
    echo "Wrong call. Should be: $0 input_transcriptions wav_dir model_dir graph_dir output_dir"
    exit 1
fi

##################
# Input arguments:
##################
input_transcriptions=$1
wav_dir=$2
model_dir=$3
graph_dir=$4
output_dir=$5

###############
# Intermediate:
###############
kaldi_output_dir="$model_dir/decode"
tmp_dir="$output_dir/tmp"
lang_dir="$output_dir/lang"
wav_lst="$tmp_dir/wav.lst"
wav_scp="$lang_dir/wav.scp"
feats_dir="$output_dir/feats"
feats_log_dir="$output_dir/feats/log"

for f in $input_transcriptions $wav_dir $model_dir $graph_dir; do
    [[ ! -e $f ]] && echo "Error. Missing input $f" && exit 1
done

# This call selects the tool used for parallel computing: ($train_cmd)
. cmd.sh

# This includes in the path the kaldi binaries:
. path.sh

# This parses any input option, if supplied.
. utils/parse_options.sh

mkdir -p $kaldi_output_dir $output_dir $lang_dir $tmp_dir

##
# Create the secondary files needed by Kaldi (wav.scp, utt2spk, spk2utt):
archimob/create_secondary_files.py -w $wav_dir -o $lang_dir \
				   decode -t $input_transcriptions

[[ $? -ne 0 ]] && echo 'Error calling create_secondary_files.py' && exit 1

##
# Create the features:
if [[ $do_feature_extraction -ne 0 ]]; then

    # This extracts MFCC features. See conf/mfcc.conf for the configuration
    # Note: the $train_cmd variable is defined in cmd.sh
    steps/make_mfcc.sh --cmd "$train_cmd" --nj $num_jobs $lang_dir \
		       $feats_log_dir $feats_dir

    [[ $? -ne 0 ]] && echo 'Error during feature extraction' && exit 1

    # This extracts the Cepstral Mean Normalization features:
    steps/compute_cmvn_stats.sh $lang_dir $feats_log_dir $feats_dir

    [[ $? -ne 0 ]] && echo 'Error during cmvn computation' && exit 1

fi

##
# Do decoding:
if [[ $do_decoding -ne 0 ]]; then

    rm -rf $kaldi_output_dir/*
    uzh/decode.sh --cmd "$decode_cmd" --nj $num_jobs $graph_dir \
	$lang_dir $kaldi_output_dir

    [[ $? -ne 0 ]] && echo 'Error decoding' && exit 1

fi

##
# Copy the results to the output folder:
cp $kaldi_output_dir/scoring_kaldi/best_wer $output_dir
cp -r $kaldi_output_dir/scoring_kaldi/wer_details $output_dir/

echo "Done: $0"
