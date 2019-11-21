#!/bin/bash

set -u

# This script is an interface for steps/nnet2/decode.sh. Note that it is
# designed to process the features exactly in the same way followed during
# nnet2 (and nnet2 discriminative) training. Therefore, it does not support
# decoding with GMM models.

################
# Configuration:
################
num_jobs=8  # Number of jobs for parallel processing
spn_word='<SPOKEN_NOISE>'
sil_word='<SIL_WORD>'
nsn_word='<NOISE>'

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
if [[ $# -lt 5 ]]; then
    echo "Wrong call. Should be: $0 input_csv wav_dir model_dir graph_dir output_dir ['orig'/'norm']"
    exit 1
fi

##################
# Input arguments:
##################
# input_transcriptions=$1
input_csv=$1
wav_dir=$2
model_dir=$3
graph_dir=$4
output_dir=$5
transcription=${6:-"orig"}

###############
# Intermediate:
###############
# kaldi_output_dir="$model_dir/decode"
kaldi_output_dir="$output_dir/decode" # output dir for decoding is now in decode_out/ instead of model dir
tmp_dir="$output_dir/tmp"
lang_dir="$output_dir/lang"
# wav_lst="$tmp_dir/wav.lst" # duplicate of 'output variable $output_lst (see below)'
# wav_scp="$lang_dir/wav.scp" # NOT USED!!!
feats_dir="$output_dir/feats"
feats_log_dir="$output_dir/feats/log"

#########
# Output:
#########
input_transcriptions="$tmp_dir/text"
output_lst="$tmp_dir/wav.lst"

# for f in $input_transcriptions $wav_dir $model_dir $graph_dir; do
#     [[ ! -e $f ]] && echo "Error. Missing input $f" && exit 1
# done

mkdir -p $output_dir $kaldi_output_dir $lang_dir $tmp_dir

START_TIME=$(date +%s) # record time of operations

# 1.- Create the transcriptions and wave list:
echo ""
echo "########################################################"
echo "### BEGIN: EXTRACT TEST TRANSCRIPTIONS AND WAVE LIST ###"
echo "########################################################"
echo ""
# Note the options -f and -p: we are rejecting files with no-relevant-speech or
# overlapping speech; also, Archimob markers (hesitations, coughing, ...) are
# mapped to less specific classes (see process_archimob.csv.py)
# echo "Processing $input_csv:"
archimob/process_archimob_csv.py \
  -i $input_csv \
  -trans $transcription \
  -f \
  -p \
  -t $input_transcriptions \
  --spn-word $spn_word \
  --sil-word $sil_word \
  --nsn-word $nsn_word \
  -o $output_lst

[[ $? -ne 0 ]] && echo -e "\n\tERROR: calling process_archimob_csv.py\n" && exit 1

# Sort them the way Kaldi likes it:
sort $input_transcriptions -o $input_transcriptions
sort $output_lst -o $output_lst

# 2. Create the secondary files needed by Kaldi (wav.scp, utt2spk, spk2utt):
echo ""
echo "###############################################"
echo "### BEGIN: CREATE SECONDARY FILES FOR KALDI ###"
echo "###############################################"
echo ""
archimob/create_secondary_files.py \
  -w $wav_dir \
  -o $lang_dir \
  decode \
  -t $input_transcriptions

[[ $? -ne 0 ]] && echo -e "\n\tERROR: calling create_secondary_files.py\n" && exit 1

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

# 3. Create the features:
if [[ $do_feature_extraction -ne 0 ]]; then
    echo ""
    echo "#################################"
    echo "### BEGIN: FEATURE EXTRACTION ###"
    echo "#################################"
    echo ""
    # This extracts MFCC features. See conf/mfcc.conf for the configuration
    # Note: the $train_cmd variable is defined in cmd.sh
    steps/make_mfcc.sh --cmd "$train_cmd" --nj $num_jobs $lang_dir \
		      $feats_log_dir $feats_dir

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: during feature extraction\n" && exit 1

    # This extracts the Cepstral Mean Normalization features:
    steps/compute_cmvn_stats.sh $lang_dir $feats_log_dir $feats_dir

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: during cmvn computation\n" && exit 1

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

fi

##
# Do DECODING:
if [[ $do_decoding -ne 0 ]]; then

    echo ""
    echo "#######################"
    echo "### BEGIN: DECODING ###"
    echo "#######################"
    echo ""

    rm -rf $kaldi_output_dir/*
    uzh/decode.sh --cmd "$decode_cmd" --nj $num_jobs $graph_dir \
        $lang_dir $kaldi_output_dir $model_dir

    [[ $? -ne 0 ]] && echo -e '\n\tERROR: during decoding\n' && exit 1

fi

# Copy the results to the output folder:
cp $kaldi_output_dir/scoring_kaldi/best_wer $output_dir
cp -r $kaldi_output_dir/scoring_kaldi/wer_details $output_dir/

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

echo ""
echo "### DONE: $0 ###"
echo ""
