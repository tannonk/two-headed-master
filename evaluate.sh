#!/bin/bash

set -u

# This script is an adaption of the original decode_nnet.sh .
# It is intended to be used on evaluation test data.
# Some variable names have been changed to make things clearer.
# Note that it is designed to process the features exactly in the
# same way followed during nnet2 (and nnet2 discriminative) training.
# Therefore, it does not support decoding with GMM models.

################
# Configuration:
################
num_jobs=32  # Number of jobs for parallel processing
spn_word='<SPOKEN_NOISE>'
sil_word='<SIL_WORD>'

#####################################
# Flags to choose with stages to run:
#####################################
do_data_prep=1
do_feature_extraction=1
do_decoding=1
# do_f1_scoring=1

# This call selects the tool used for parallel computing: ($train_cmd)
. cmd.sh

# This includes in the path the kaldi binaries:
. path.sh

# This parses any input option, if supplied.
. utils/parse_options.sh

echo $0 $@
if [[ $# -lt 5 ]]; then
    echo "Wrong call. Should be: $0 test_csv wav_dir graph_dir output_dir ['orig'/'norm']"
    exit 1
fi

##################
# Input arguments:
##################
# test_transcriptions=$1
test_csv=$1 # test csv file
wav_dir=$2 # directory containing audio files
am_dir=$3 # am_out directory (output of train_AM.sh, usually am_out/)
graph_dir=$4 # out_ling, i.e. dir containing HCLG.fst
output_dir=$5 # output directory for evaluation results
lmwt=${6:-"9"} # this should be provided based upon the results of dev set tuning
transcription=${7:-"orig"}

###############
# Intermediate:
###############

model_dir="$am_dir/models/discriminative/nnet_disc" # final model created by train_am
kaldi_output_dir="$output_dir/decode" # output dir for decoding is now explicit
tmp_dir="$output_dir/tmp"
lang_dir="$output_dir/lang" # cmvn.scp feats.scp spk2utt split32 text utt2spk wav.scp
feats_dir="$output_dir/feats"
feats_log_dir="$output_dir/feats/log"

#########
# Output:
#########
test_transcriptions="$tmp_dir/text"
wav_lst="$tmp_dir/wav.lst"

#####################################################################################

for f in $wav_dir $model_dir $graph_dir; do
    [[ ! -e $f ]] && echo "Error. Missing input $f" && exit 1
done

mkdir -p $output_dir $kaldi_output_dir $lang_dir $tmp_dir

START_TIME=$(date +%s) # record time of operations

####################
## 1. Prep TEST Data
####################

if [[ $do_data_prep -ne 0 ]]; then
    # 1.- Create the transcriptions and wave list:
    echo ""
    echo "########################################################"
    echo "### BEGIN: EXTRACT TEST TRANSCRIPTIONS AND WAVE LIST ###"
    echo "########################################################"
    echo ""
    # Note the options -f and -p: we are rejecting files with no-relevant-speech or
    # overlapping speech; also, Archimob markers (hesitations, coughing, ...) are
    # mapped to less specific classes (see process_archimob.csv.py)
    # echo "Processing $test_csv:"
    archimob/process_archimob_csv.py \
      -i $test_csv \
      -trans $transcription \
      -f \
      -p \
      -t $test_transcriptions \
      -s $spn_word \
      -n $sil_word \
      -o $wav_lst

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling process_archimob_csv.py\n" && exit 1

    # Sort them the way Kaldi likes it:
    sort $test_transcriptions -o $test_transcriptions
    sort $wav_lst -o $wav_lst

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
      -t $test_transcriptions

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling create_secondary_files.py\n" && exit 1

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

fi

#######################
## 2. Extract features:
#######################

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


##############
## 3. Decoding
##############

if [[ $do_decoding -ne 0 ]]; then

    echo ""
    echo "#######################"
    echo "### BEGIN: DECODING ###"
    echo "#######################"
    echo ""

    rm -rf $kaldi_output_dir/*
    uzh/decode_wer_cer.sh \
    --cmd "$decode_cmd" \
    --nj $num_jobs \
    --scoring_opts "--min-lmwt $lmwt --max-lmwt $lmwt" \
    $graph_dir \
    $lang_dir \
    $kaldi_output_dir \
    $model_dir

    [[ $? -ne 0 ]] && echo -e '\n\tERROR: during decoding\n' && exit 1

fi


CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""
echo ""
echo "### DONE: $0 ###"
echo ""
