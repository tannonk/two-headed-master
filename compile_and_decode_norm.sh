#!/bin/bash

set -u # from train_am.sh and compile_lingware.sh and decode_nnet.sh
export LC_ALL=C # from compile_lingware.sh

## This script is a combination of compile_lingware.sh and decode_nnet.sh
## First, we compile the lingware to run the decoder with certain input
## lexicon, language model, and acoustic models.
## Second, we extract features from test data.
## Finally, we decode the test data using the compiled graph.

# Get the general configuration variables (SPOKEN_NOISE_WORD, SIL_WORD and
# GRAPHEMIC_CLUSTERS)
. uzh/configuration.sh

# This call selects the tool used for parallel computing: ($train_cmd,
# $decode_cmd)
. cmd.sh

# This includes in the path the kaldi binaries:
. path.sh

# This parses any input option, if supplied.
. utils/parse_options.sh

# Relevant for decoding
num_jobs=8  # Number of jobs for parallel processing
spn_word='<SPOKEN_NOISE>'
sil_word='<SIL_WORD>'
nsn_word='<NOISE>'

#####################################
# Flags to choose with stages to run:
#####################################
do_compile_graph=1
do_data_prep=1
do_feature_extraction=1
do_decoding=1
do_f1_scoring=1
do_wer_flex_scoring=1

##################
# Input arguments:
##################

lm=$1 # path to language model
am_dir=$2 # am_out directory (output of train_AM.sh, usually am_out/)
dev_csv=$3 # dev csv for decoding
wav_dir=$4 # audio files for decoding
output_dir=$5 # can be shared between compile and decode
transcription=${6:-"orig"}
scoring_opts=${7:-"--min-lmwt 7 --max-lmwt 17"}
n2d_mapping=${8:-"/mnt/tannon/corpus_data/norm2dieth.json"}
# vocabulary=${9:-''}
lexicon=${9:-''}
# n2d_mapping=${8:-""}


#################
# Existing files: cf. am_out/initial_data/ling/ vs am_out/data/lang/
#################

am_ling_dir="$am_dir/initial_data/ling/" # equivalent to data/local/lang (input)
phone_table="$am_dir/data/lang/phones.txt" # created by train_am
model_dir="$am_dir/models/discriminative/nnet_disc" # final model created by train_am

###########################
# Intermediate Directories:
###########################

# lexicon="$tmp_dir/lexicon.txt" # created in train_am, removed to reduce
# repetition!
tmp_dir="$output_dir/tmp"
lexicon_tmp="$tmp_dir/lexicon"
prepare_lang_tmp="$tmp_dir/prepare_lang_tmp"
tmp_lang="$tmp_dir/lang"

decode_dir="$output_dir/decode" # output dir for decoding
lang_dir="$output_dir/lang" # output dir for intermediate language data
feats_dir="$output_dir/feats"
feats_log_dir="$output_dir/feats/log"
# wav_scp="$lang_dir/wav.scp" NOT USED !!!

##########
## Output:
##########

wav_lst="$tmp_dir/wav.lst"
dev_transcriptions="$tmp_dir/text"

#####################################################################################

# check dependencies for compiling graph
for f in $lm $phone_table; do
    [[ ! -e $f ]] && echo -e "\n\tERROR: missing input $f\n" && exit 1
done

mkdir -p $output_dir $tmp_dir $lexicon_tmp $prepare_lang_tmp $tmp_lang $decode_dir $lang_dir $feats_dir $feats_log_dir

# . ./path.sh

START_TIME=$(date +%s) # record time of operations

###################
## 1. Compile graph
###################

if [[ $do_compile_graph -ne 0 ]]; then

    if [[ ! -z $lexicon ]]; then
      
      echo -e "\nDecoding lexicon provided as $lexicon\n"

      # copy the input lexicon to the graph lang directory
      cp $lexicon $lexicon_tmp/lexicon.txt

      # lexicon="$lexicon_tmp/lexicon.txt"

      # ensure to the lexicon the mapping for the silence word:
      echo -e "$NOISE_WORD NSN\n$SIL_WORD SIL\n$SPOKEN_NOISE_WORD SPN\n" | cat - $lexicon_tmp/lexicon.txt | \
          sort | uniq | sort -o $lexicon_tmp/lexicon.txt

      sed -i '/^$/d' $lexicon_tmp/lexicon.txt

      # Generate the lexicon fst:
      for f in nonsilence_phones.txt optional_silence.txt silence_phones.txt; do
          [[ ! -e $am_ling_dir/$f ]] && echo -e "\n\tERROR: missing $f in $am_ling_dir\n" && \
        exit 1
          cp $am_ling_dir/$f $lexicon_tmp/
      done

      # rm $lexiconp.txt quietly
      rm $lexicon_tmp/lexiconp.txt &> /dev/null
    
    else

      echo -e "\nNo decoding lexicon provided. Graph will be compiled with lexicon used for AM training...\n"

      for f in lexicon.txt nonsilence_phones.txt optional_silence.txt silence_phones.txt; do
          [[ ! -e $am_ling_dir/$f ]] && echo -e "\n\tERROR: missing $f in $am_ling_dir\n" && exit 1
          cp $am_ling_dir/$f $lexicon_tmp/
      done

    fi    
    

    echo ""
    echo "######################################"
    echo "### BEGIN: PREPARING LANGUAGE DATA ###"
    echo "######################################"
    echo ""

    utils/prepare_lang.sh \
      --phone-symbol-table $phone_table \
      $lexicon_tmp \
      "$SPOKEN_NOISE_WORD" \
      $prepare_lang_tmp \
      $tmp_lang

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling prepare_lang.sh\n" && exit 1

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

    echo ""
    echo "##############################"
    echo "### BEGIN: GENERATE LM FST $tmp_lang/G.fst ###"
    echo "##############################"
    echo ""

    # Generate G.fst (grammar / language model):
    arpa2fst --disambig-symbol=#0 \
      --read-symbol-table=$tmp_lang/words.txt \
      $lm \
      $tmp_lang/G.fst

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: generating $tmp_lang/G.fst\n" && exit 1

    set +e # don't exit on error
    fstisstochastic $tmp_lang/G.fst
    set -e # exit on error

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

    echo ""
    echo "#############################"
    echo "### BEGIN: GENERATE GRAPH ###"
    echo "#############################"
    echo ""

    # Generate the complete cascade:
    utils/mkgraph.sh $tmp_lang $model_dir $output_dir

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling mkgraph.sh\n" && exit 1

    echo ""
    echo "#####################################"
    echo "### COMPLETED: CONSTRUCTING GRAPH ###"
    echo "#####################################"
    echo ""

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""


fi

###########################
## 2. Prep DEVELOPMENT Data
###########################

if [[ $do_data_prep -ne 0 ]]; then
    # 1.- Create the transcriptions and wave list:
    echo ""
    echo "#######################################################"
    echo "### BEGIN: EXTRACT DEV TRANSCRIPTIONS AND WAVE LIST ###"
    echo "#######################################################"
    echo ""
    # Note the options -f and -p: we are rejecting files with no-relevant-speech
    # or overlapping speech; also, Archimob markers (hesitations, coughing, ...)
    # are mapped to less specific classes (see process_archimob.csv.py) 
    
    # echo "Processing $dev_csv:"
    archimob/process_archimob_csv.py \
      -i $dev_csv \
      -trans $transcription \
      -f \
      -p \
      -t $dev_transcriptions \
      --spn-word $spn_word \
      --sil-word $sil_word \
      --nsn-word $nsn_word \
      -o $wav_lst

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling process_archimob_csv.py\n" && exit 1

    # Sort them the way Kaldi likes it:
    sort $dev_transcriptions -o $dev_transcriptions
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
      -t $dev_transcriptions

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling create_secondary_files.py\n" && exit 1

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

fi

#######################
## 3. Extract features:
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
## 4. Decoding
##############

# dependencies for decoding for f in $dev_transcriptions $wav_dir $model_dir ;
# do [[ ! -e $f ]] && echo "Error. Missing input $f" && exit 1 done

# $output_dir --> graphdir=$1 srcdir=`dirname $dir`; # Assume model directory
# one level up from decoding directory $lang_dir --> data=$2 $decode_dir -->
# dir=$3 $model_dir --> srcdir=$4

if [[ $do_decoding -ne 0 ]]; then

    echo ""
    echo "#######################"
    echo "### BEGIN: DECODING ###"
    echo "#######################"
    echo ""

    rm -rf $decode_dir/*
    uzh/decode_wer_cer.sh --scoring_opts "$scoring_opts" \
      --cmd "$decode_cmd" \
      --nj $num_jobs $output_dir \
      $lang_dir $decode_dir $model_dir

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: during decoding\n" && exit 1

    # Copy the results to the output folder:
    cp $decode_dir/scoring_kaldi/best_wer $output_dir
    cp $decode_dir/scoring_kaldi/best_cer $output_dir
    # cp -r $decode_dir/scoring_kaldi/wer_details $output_dir

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

fi

if [[ $transcription == "orig" ]]; then

    if [[ $do_f1_scoring -ne 0 ]]; then

        echo ""
        echo "#########################"
        echo "### BEGIN: F1 SCORING ###"
        echo "#########################"
        echo ""

        [[ ! -f $n2d_mapping ]] && echo -e "\n\tERROR: Cannot score F1. Missing $n2d_mapping\n" && exit 1

        uzh/score_f1.sh $decode_dir $n2d_mapping

        [[ $? -ne 0 ]] && echo -e "\n\tERROR: during F1 scoring\n" && exit 1
        
    fi

    if [[ $do_wer_flex_scoring -ne 0 ]]; then

    echo ""
    echo "###############################"
    echo "### BEGIN: WER FLEX SCORING ###"
    echo "###############################"
    echo ""

    [[ ! -f $n2d_mapping ]] && echo -e "\n\tERROR: Cannot score F1. Missing $n2d_mapping\n" && exit 1

    uzh/score_flex_wer.sh $decode_dir $n2d_mapping

    [[ $? -ne 0 ]] && echo -e "\n\tERROR: during flex wer scoring\n" && exit 1
    
    fi

else # do flex wer scoring without norm2dieth mapping

    if [[ $do_wer_flex_scoring -ne 0 ]]; then
      echo ""
      echo "###############################"
      echo "### BEGIN: WER FLEX SCORING ###"
      echo "###############################"
      echo ""

      uzh/score_flex_wer.sh $decode_dir

      [[ $? -ne 0 ]] && echo -e "\n\tERROR: during flex wer scoring\n" && exit 1

    fi

fi

python3 evaluation/find_best_scores.py $decode_dir

cp $decode_dir/scoring_kaldi/best_flexwer $output_dir 2>/dev/null || :
cp $decode_dir/scoring_kaldi/best_f1 $output_dir 2>/dev/null || :


CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""
echo ""
echo "### DONE: $0 ###"
echo ""
