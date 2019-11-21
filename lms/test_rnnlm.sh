#!/bin/bash

##
## This is an adaption of the train.sh example script shipped with RNNLM [Mivolov 2012]
##

rnnpath=../rnnlm-0.3e
trainfile=../data/ptb.train.txt
validfile=../data/ptb.valid.txt
testfile=../data/ptb.test.txt
rnnmodel=../models/ptb.model.hidden100.class100.txt
temp=../temp

if [ ! -e $rnnmodel ]; then
    echo "model file not found... run first train.sh"
    exit
fi

#################################################
# N-GRAM MODEL IS TRAINED HERE, USING SRILM TOOLS
#################################################

ngram-count -text $trainfile -order 5 -lm $temp/templm -gt3min 1 -gt4min 1 -kndiscount -interpolate -unk
ngram -lm $temp/templm -order 5 -ppl $testfile -debug 2 > $temp/temp.ppl -unk

$rnnpath/convert <$temp/temp.ppl >$temp/ngram.txt

##################################################
# MODELS ARE COMBINED HERE, PERPLEXITY IS REPORTED
##################################################

time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.1
time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.2
time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.3
time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.5
time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.7
time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.8
time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.9
