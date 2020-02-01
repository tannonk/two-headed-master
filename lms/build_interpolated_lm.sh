#!/bin/bash

### WARNING: RUN AS INDIVIDUAL COMMANDS COPYING AND PASTING TO TERMINAL!

# set -u
# set -e

#### original

estimate-ngram -text /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt -write-lm archi.lm
estimate-ngram -text /mnt/tannon/corpus_data/gsw_data/proc.ch_web_2017.txt -write-lm ch_web.lm
estimate-ngram -text /mnt/tannon/corpus_data/gsw_data/proc.noah.txt -write-lm noah.lm
# estimate-ngram -text /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt -write-lm tatoeba.lm
estimate-ngram -text /mnt/tannon/corpus_data/gsw_data/proc.transcripts_phonogrammarchiv.txt -write-lm phono.lm
estimate-ngram -text /mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt -write-lm schaw.lm

interpolate-ngram -lm archi.lm,ch_web.lm,noah.lm,phono.lm,schaw.lm -opt-perp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt -eval-perp /mnt/tannon/corpus_data/csv_files/test_files/test_orig_utt.txt -write-lm orig_interpolated.arpa



#### norm

estimate-ngram -text /mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt -write-lm archi.lm
estimate-ngram -text /mnt/tannon/corpus_data/de_data/opensubtitles_de_sample.txt -write-lm opensub.lm
estimate-ngram -text /mnt/tannon/corpus_data/de_data/tatoeba_de.txt -write-lm tatoeba.lm
# estimate-ngram -text /mnt/tannon/corpus_data/de_data/tuda_speech_de.txt -write-lm tuda.lm
estimate-ngram -text /mnt/tannon/corpus_data/de_data/tueba-ds.w.txt -write-lm tueba.lm

interpolate-ngram -lm archi.lm,opensub.lm,tatoeba.lm,tueba.lm -opt-perp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_norm_utt.txt -eval-perp /mnt/tannon/corpus_data/csv_files/test_files/test_norm_utt.txt -write-lm norm_interpolated.arpa




## example:

# ARGS=("$@")
# LEN=${#ARGS[@]}
# OUTDIR=${ARGS[$LEN-1]} # assumed to be the last arg
# TEST=${ARGS[$LEN-2]} # assumed to be the second last arg
# DEV=${ARGS[$LEN-3]} 
# FILES=(${ARGS[@]:0:$LEN-3}) # assumed to be all args up until the 3rd last
# FILES=($FILES)
# n=3

# echo "Test file: $TEST"
# echo "Dev file: $DEV"
# echo "Building LMs for the following files: $FILES"

# for i in "${!FILES[@]}"; do 
# #   echo "$i" "${FILES[$i]}"
#     out_lm=$OUTDIR/lm_$i.arpa
#     echo $out_lm
#     estimate-ngram -order $n \
#         -text ${FILES[$i]} \
#         -smoothing "ModKN" \
#         -write-lm $out_lm
# done

