#!/bin/bash

set -u
set -e

## example:
## nohup bash /home/tannon/kaldi_wrk/two-headed-master/lms/incremental_training_data.sh train.txt 1000000 > log.txt&

dir=$1
maxn=${2:-200000}
vocabulary=${3:-''}

step=10000
minn=10000
train_file=$dir/train.txt
dev_file=$dir/dev.txt
test_file=$dir/test.txt
# vocabulary=$dir/vocab.txt

lm_order=3

mkdir -p $dir/splits

# sed -i 's/ß/ss/g' train.txt

for n in $(seq $minn $step $maxn); do

    # echo "$n"

    head -n$n $train_file > $dir/splits/train_$n.txt
    
    echo "Training on $dir/splits/train_$n.txt..."

    if [[ ! -z $vocabulary ]]; then

        estimate-ngram -order $lm_order \
            -text $dir/splits/train_$n.txt \
            -opt-perp $dev_file \
            -eval-perp $test_file \
            -vocab $vocabulary \
            -unk "true"

        wait 

        rm $dir/splits/train_$n.txt

    else
        
        estimate-ngram -order $lm_order \
            -text $dir/splits/train_$n.txt \
            -opt-perp $dev_file \
            -eval-perp $test_file \
            -vocab $vocabulary
        
        wait 

        rm $dir/splits/train_$n.txt

    fi


done


# estimate-ngram -order $lm_order \
#     -text $dir/splits/train_$n.txt \
#     -opt-perp $dev_file \
#     -eval-perp $test_file \
#     -vocab $vocabulary

# all_data_train=$( cat $train_file /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt /mnt/tannon/corpus_data/gsw_data/proc.noah.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_phonogrammarchiv.txt /mnt/tannon/corpus_data/gsw_data/proc.ch_web_2017.txt )

# echo `cat $all_data_train | wc`

# cat $train_file /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt > $dir/splits/inc1.txt
# echo "Training on $dir/splits/inc1.txt..."
# estimate-ngram -order $lm_order \
#     -text $dir/splits/inc1.txt \
#     -opt-perp $dev_file \
#     -eval-perp $test_file

# cat $train_file /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt > $dir/splits/inc2.txt
# echo "Training on $dir/splits/inc2.txt..."
# estimate-ngram -order $lm_order \
#     -text $dir/splits/inc2.txt \
#     -opt-perp $dev_file \
#     -eval-perp $test_file

# cat $train_file /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt /mnt/tannon/corpus_data/gsw_data/proc.noah.txt > $dir/splits/inc3.txt
# echo "Training on $dir/splits/inc3.txt..."
# estimate-ngram -order $lm_order \
#     -text $dir/splits/inc3.txt \
#     -opt-perp $dev_file \
#     -eval-perp $test_file

# cat $train_file /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt /mnt/tannon/corpus_data/gsw_data/proc.noah.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_phonogrammarchiv.txt > $dir/splits/inc4.txt
# echo "Training on $dir/splits/inc4.txt..."
# estimate-ngram -order $lm_order \
#     -text $dir/splits/inc4.txt \
#     -opt-perp $dev_file \
#     -eval-perp $test_file

# cat $train_file /mnt/tannon/corpus_data/gsw_data/proc.tatoeba_gsw.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt /mnt/tannon/corpus_data/gsw_data/proc.noah.txt /mnt/tannon/corpus_data/gsw_data/proc.transcripts_phonogrammarchiv.txt /mnt/tannon/corpus_data/gsw_data/proc.ch_web_2017.txt > $dir/splits/inc4.txt
# echo "Training on $dir/splits/inc4.txt..."
# estimate-ngram -order $lm_order \
#     -text $dir/splits/inc4.txt \
#     -opt-perp $dev_file \
#     -eval-perp $test_file

echo "### Done $0 ###"
