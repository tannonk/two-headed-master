#!/bin/bash

word_ins_penalty=0.0,0.5,1.0
for wip in $(echo $word_ins_penalty | sed 's/,/ /g'); do
  for lmwt in $(seq 7 17); do
    grep WER /home/tannon/kaldi_wrk_dir/toy_kaldi/toy_out/out_AM/models/discriminative/nnet_disc/decode/wer_${lmwt}_${wip} /dev/null
  done
done
