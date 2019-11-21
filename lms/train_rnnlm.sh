#!/bin/bash

##
## This is an adaption of the train.sh example script shipped with RNNLM [Mivolov 2012]
##

##################
## Input Arguments
##################

rnnpath=$1 # ../rnnlm-0.3e
trainfile=$2 # ../data/ptb.train.txt
validfile=$3 # ../data/ptb.valid.txt
testfile=$4 # ../data/ptb.test.txt
rnnmodel=$5 # ../models/ptb.model.hidden100.class100.txt
temp=$6 # "./temp"

#########
## Config
#########
hidden_size=100
class_size=100
bptt_steps=4

## Establish temp dir if doesn't exist
mkdir -p $temp

#################################
# CHECK FOR 'rnnlm' AND 'convert'
#################################

if [ ! -e $rnnpath/rnnlm ]; then
    echo "Compiling RNNLM in $rnnpath"
    make clean -C $rnnpath
    make -C $rnnpath
fi

if [ ! -e $rnnpath/rnnlm ]; then
    echo "Cannot compile rnnlm tool";
    exit
fi

if [ ! -e $rnnpath/convert ]; then
    gcc $rnnpath/convert.c -O2 -o $rnnpath/convert
fi

#################################################
# IF MODEL FILE ALREADY EXISTS, IT WILL BE ERASED
#################################################

if [ -e $rnnmodel ]; then
    rm $rnnmodel
fi

if [ -e $rnnmodel.output.txt ]; then
    rm $rnnmodel.output.txt
fi

################################
# TRAINING OF RNNLM HAPPENS HERE
################################

time $rnnpath/rnnlm -train $trainfile -valid $validfile -rnnlm $rnnmodel -hidden $hidden_size -rand-seed 1 -debug 2 -class $class_size -bptt $bptt_steps -bptt-block 10

#################################################
# N-GRAM MODEL IS TRAINED HERE, USING MITLM TOOLS
#################################################

estimate-ngram \
  -t $trainfile \
  -o 3 \
  -unk true \
  -opt-perp $validfile \
  -eval-perp $testfile \
  -wl $temp/templm

# This uses SRILM to get the right output
ngram -lm $temp/templm -order 3 -ppl $testfile -debug 2 > $temp/temp.ppl -unk

$rnnpath/convert < $temp/temp.ppl > $temp/ngram.txt

#################################################
# N-GRAM MODEL IS TRAINED HERE, USING SRILM TOOLS
#################################################

#we use -unk switch for srilm tools, as the data contain <unk> tokens for unknown words
#as we have rewritten all out of vocabulary words in the validation and test data to <unk> tokens, we do not need any special parameters to rnnlm tool
#you can check that the results are correct by replacing <unk> toknes by other (like <unknown>) and training closed vocabulary models

# ngram-count -text $trainfile -order 5 -lm $temp/templm -gt3min 1 -gt4min 1 -kndiscount -interpolate -unk
# ngram -lm $temp/templm -order 5 -ppl $testfile -debug 2 > $temp/temp.ppl -unk
#
# $rnnpath/convert <$temp/temp.ppl >$temp/ngram.txt

##################################################
# MODELS ARE COMBINED HERE, PERPLEXITY IS REPORTED
##################################################

time $rnnpath/rnnlm -rnnlm $rnnmodel -test $testfile -lm-prob $temp/ngram.txt -lambda 0.5
