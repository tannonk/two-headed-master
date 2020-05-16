# data preparation step for ArchiMob data
# processes ArchiMob CSV file and organises input for Kaldi

##################
# Input arguments:
##################
input_csv=$1
input_wav_dir=$2
output_dir=$3
trans=${4:-"orig"}
pron_lex=${5:-""}

###############
# Intermediate:
###############
tmp_dir="$output_dir/tmp"
initial_data="$output_dir/initial_data"
lang_tmp="$tmp_dir/lang_tmp"
data="$output_dir/data"

# Get the general configuration variables (SPOKEN_NOISE_WORD, SIL_WORD, and
# GRAPHEMIC_CLUSTERS)
. uzh/configuration.sh

for f in $input_csv $GRAPHEMIC_CLUSTERS $input_wav_dir; do
    [[ ! -e $f ]] && echo -e "\n\tERROR: missing $f\n" && exit 1
done

# if [[ $trans != "orig" && $trans != "norm" ]]; then
#     echo -e "\n\tERROR: $trans is an invalid transcription type." \
#     "Transcription type must be either 'orig' (default) or 'norm'."
#     exit 1
# fi

# if [[ $trans = "norm" && ! -e $pron_lex ]]; then
#     echo -e "\n\tERROR: missing $pron_lex which is required when working with normalised transcriptions. Provide a SAMPA dictionary or Dieth dictionary.\n"
#     exit 1
# fi

# mkdir -p $output_dir

# START_TIME=$(date +%s) # record time of operations


# prepare_Archimob_training_files_09.04.20.sh



# if [[ $do_archimob_preparation -ne 0 ]]; then

#     echo ""
#     echo "###################################"
#     echo "### BEGIN: ARCHIMOB PREPARATION ###"
#     echo "###################################"
#     echo ""

#     if [[ ! -z $pron_lex ]]; then
#       archimob/prepare_Archimob_training_files.sh \
#         -s "$SPOKEN_NOISE_WORD" \
#         -n "$SIL_WORD" \
#         -t $trans \
#         -p $pron_lex \
#         $input_csv \
#         $input_wav_dir \
#         $GRAPHEMIC_CLUSTERS \
#         $initial_data

#       [[ $? -ne 0 ]] && echo -e "\n\tERROR: preparing Archimob training files\n" && exit 1

#     else
#       archimob/prepare_Archimob_training_files.sh \
#       -s "$SPOKEN_NOISE_WORD" \
#       -n "$SIL_WORD" \
#       -t $trans \
#       $input_csv \
#       $input_wav_dir \
#       $GRAPHEMIC_CLUSTERS \
#       $initial_data

#       [[ $? -ne 0 ]] && echo -e "\n\tERROR: preparing Archimob training files\n" && exit 1

#     fi

#     CUR_TIME=$(date +%s)
#     echo ""
#     echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
#     echo ""

# fi



# # From this moment on, all the data is organized the way Kaldi likes

# if [[ $do_data_preparation -ne 0 ]]; then

#     echo ""
#     echo "#####################################"
#     echo "### BEGIN: KALDI DATA PREPARATION ###"
#     echo "#####################################"
#     echo ""

#     utils/prepare_lang.sh \
#       $initial_data/ling \
#       $SPOKEN_NOISE_WORD \
#       $lang_tmp \
#       $data/lang

#     [[ $? -ne 0 ]] && echo -e "\n\tERROR: calling prepare_lang.sh\n" && exit 1

#     CUR_TIME=$(date +%s)
#     echo ""
#     echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
#     echo ""

# fi
