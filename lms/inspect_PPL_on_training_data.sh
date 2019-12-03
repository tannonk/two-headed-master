#!/bin/bash

set -u

dir=$1

train_file=$dir/train.txt
dev_file=$dir/dev.txt
test_file=$dir/test.txt

lm_order=3

mkdir -p $dir/splits

for n in {10000..80000..10000}; do 
    
    head -n$n $train_file > $dir/splits/train_$n.txt
    
    echo "Training on $dir/splits/train_$n.txt..."

    estimate-ngram -order $lm_order \
          -text $dir/splits/train_$n.txt \
          -opt-perp $dev_file \
          -eval-perp $test_file
    
    done

echo "### Done $0 ###"
