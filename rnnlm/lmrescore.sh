#!/bin/bash

# Copyright 2015  Guoguo Chen
#           2017  Hainan Xu
# Apache 2.0

# This script rescores lattices with KALDI RNNLM.

################
## Configuration
################

do_lattice_rescore=1
do_scoring=1
# skip_scoring=false


cmd=run.pl
max_ngram_order=5 #4 # Approximate the lattice-rescoring by limiting the max-ngram-order
                  # if it's set, it merges histories in the lattice if they share
                  # the same ngram history and this prevents the lattice from 
                  # exploding exponentially. Details of the n-gram approximation
                  # method are described in section 2.3 of the paper
                  # http://www.cs.jhu.edu/~hxu/tf.pdf

weight=0.5  # Interpolation weight for RNNLM.
normalize=false # If true, we add a normalization step to the output of the RNNLM
                # so that it adds up to *exactly* 1. Note that this is not necessary
                # as in our RNNLM setup, a properly trained network would automatically
                # have its normalization term close to 1. The details of this
                # could be found at http://www.cs.jhu.edu/~hxu/rnnlm.pdf


echo "$0 $@"  # Print the command line for logging

[ -f ./path.sh ] && . ./path.sh; # source the path.
. parse_options.sh || exit 1;

if [ $# -lt 5 ]; then
   echo "Does language model rescoring of lattices (remove old LM, add new LM)"
   echo "with Kaldi RNNLM."
   echo ""
   echo "Usage: $0 [options] <old-lang-dir> <rnnlm-dir> \\"
   echo "                   <data-dir> <input-decode-dir> <output-decode-dir>"
   echo " e.g.: $0 data/lang_tg exp/rnnlm_lstm/ data/test \\"
   echo "                   exp/tri3/test_tg exp/tri3/test_rnnlm_4gram"
   echo "options: [--cmd (run.pl|queue.pl [queue opts])]"
   exit 1;
fi

[ -f path.sh ] && . ./path.sh;

#############
## Input Args
#############

# /mnt/tannon/processed/archimob_r1/orig/rnnlm_rescore/lw_out/tmp/lang/
oldlang=$1

# /mnt/tannon/processed/archimob_r1/orig/rnnlm_rescore/rnnlm/out/
rnnlm_dir=$2

# /mnt/tannon/processed/archimob_r1/orig/rnnlm_rescore/lw_out/lang
# (same data dir as passed to score in decode_wer_cer.sh)
data=$3

# /mnt/tannon/processed/archimob_r1/baseline/orig/rnnlm_rescore/lw_out/decode
indir=$4

# /mnt/tannon/processed/archimob_r1/orig/rnnlm_rescore/rescore_out
outdir=$5

min_lmwt=${6:-7}
max_lmwt=${7:-17}

# if provided, F1 is scored using uzh/score_f1.sh, which
# calls uzh/scherrer_eval.py e.g.
# /mnt/tannon/corpus_data/norm2dieth.json
n2d_mapping=${8:-""}

if [[ $min_lmwt -gt $max_lmwt ]]; then
    echo -e "\tERROR: min LMWT cannot be greater than max LMWT" && exit 1;
fi

START_TIME=$(date +%s) # record time of operations

echo ""
echo "##################################"
echo "### BEGIN: SETTING CONFIG VARS ###"
echo "##################################"
echo ""

oldlm=$oldlang/G.fst
if [ -f $oldlang/G.carpa ]; then
  oldlm=$oldlang/G.carpa
elif [ ! -f $oldlm ]; then
  echo "$0: expecting either $oldlang/G.fst or $oldlang/G.carpa to exist" &&\
    exit 1;
fi

[ ! -f $oldlm ] && echo "$0: Missing file $oldlm" && exit 1;
[ ! -f $rnnlm_dir/final.raw ] && echo "$0: Missing file $rnnlm_dir/final.raw" && exit 1;
[ ! -f $rnnlm_dir/feat_embedding.final.mat ] && [ ! -f $rnnlm_dir/word_embedding.final.mat ] && echo "$0: Missing word embedding file" && exit 1;

[ ! -f $oldlang/words.txt ] &&\
  echo "$0: Missing file $oldlang/words.txt" && exit 1;
! ls $indir/lat.*.gz >/dev/null &&\
  echo "$0: No lattices in input directory $indir" && exit 1;
awk -v n=$0 -v w=$weight 'BEGIN {if (w < 0 || w > 1) {
  print n": Interpolation weight should be in the range of [0, 1]"; exit 1;}}' \
  || exit 1;


# oldlm_command="fstproject --project_output=true $oldlm |"
oldlm_command="/opt/kaldi/tools/openfst-1.6.5/bin/fstproject --project_output=true $oldlm |"

# special symbol options file is not empty, fill variable
# with contents, otherwise, set variable explicitly
if [ -s $rnnlm_dir/special_symbol_opts.txt ]; then
    special_symbol_opts=$(cat $rnnlm_dir/special_symbol_opts.txt)
else
    special_symbol_opts="--bos-symbol=1 --eos-symbol=2 --brk-symbol=3"
fi

word_embedding=
if [ -f $rnnlm_dir/word_embedding.final.mat ]; then
  word_embedding=$rnnlm_dir/word_embedding.final.mat
else
  word_embedding="'rnnlm-get-word-embedding $rnnlm_dir/word_feats.txt $rnnlm_dir/feat_embedding.final.mat -|'"
fi

normalize_opt=
if $normalize; then
  normalize_opt="--normalize-probs=true"
fi

mkdir -p $outdir/log
nj=$(cat $indir/num_jobs) || exit 1;
cp $indir/num_jobs $outdir

oldlm_weight=$(perl -e "print -1.0 * $weight;")

# echo ""
# echo "### CONFIGURATION VARIABLES SET AS:"
# echo -e "\tCMD: $cmd"
# echo -e "\tNUM JOBS: $nj"
# echo -e "\tOUTPUT DIR: $outdir"
# echo -e "\tOLD LM WEIGHT: $oldlm_weight"
# echo -e "\tINTERPOLATION WEIGHT: $weight"
# echo -e "\tSPECIAL SYMBOL OPTS: $special_symbol_opts"
# echo -e "\tMAX NGRAM ORDER: $max_ngram_order"
# echo -e "\tNORMALIZE OPT: $normalize_opt"
# echo -e "\tWORD EMBEDDING: $word_embedding"
# echo "" 

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

if [[ $do_lattice_rescore -ne 0 ]]; then

    echo ""
    echo "#################################"
    echo "### BEGIN: RESCORING LATTICES ###"
    echo "#################################"
    echo ""

    if [ "$oldlm" == "$oldlang/G.fst" ]; then
        echo -e "\tRescoring with lattice-lmrescore"
        $cmd JOB=1:$nj $outdir/log/rescorelm.JOB.log \
          lattice-lmrescore --lm-scale=$oldlm_weight \
          "ark:gunzip -c $indir/lat.JOB.gz|" "$oldlm_command" ark:- \| \
          lattice-lmrescore-kaldi-rnnlm --lm-scale=$weight $special_symbol_opts \
          --max-ngram-order=$max_ngram_order $normalize_opt \
          $word_embedding "$rnnlm_dir/final.raw" ark:- \
          "ark,t:|gzip -c>$outdir/lat.JOB.gz"
          
          [[ $? -ne 0 ]] && echo -e "\n\tProblem with lattice-lmrescore on job number $nj\n" && exit 1
          
          #  || echo "Problem with lattice-lmrescore on job
          #  number $nj" && exit 1;
        
    else
        echo -e "\tRescoring with lattice-lmrescore-const-arpa"
        $cmd JOB=1:$nj $outdir/log/rescorelm.JOB.log \
          lattice-lmrescore-const-arpa --lm-scale=$oldlm_weight \
          "ark:gunzip -c $indir/lat.JOB.gz|" "$oldlm" ark:-  \| \
          lattice-lmrescore-kaldi-rnnlm --lm-scale=$weight $special_symbol_opts \
          --max-ngram-order=$max_ngram_order $normalize_opt \
          $word_embedding "$rnnlm_dir/final.raw" ark:- \
          "ark,t:|gzip -c>$outdir/lat.JOB.gz" 
        
        # || echo "" && exit 1;
      
        [[ $? -ne 0 ]] && echo -e "\n\tProblem with lattice-lmrescore-const-arpa on job number $nj\n" && exit 1
      
    fi

fi

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

# if ! $skip_scoring ; then
if [[ $do_scoring -ne 0 ]]; then

  echo ""
  echo "#####################################"
  echo "### BEGIN: RESCORING WITH METRICS ###"
  echo "#####################################"
  echo ""

  [ ! -x uzh/score.sh ] && echo "Not scoring because uzh/score.sh does not exist or not executable." && exit 1;
  echo -e "\nScoring best paths for WER..."
  uzh/score.sh --cmd "$cmd" --min_lmwt $min_lmwt --max_lmwt $max_lmwt $data $oldlang $outdir
  echo -e "\n### Scoring WER completed ###"

  CUR_TIME=$(date +%s)
  echo ""
  echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
  echo ""

  echo -e "\nScoring best paths for CER..."
  [ ! -x uzh/score_cer.sh ] && echo "Not scoring because uzh/score_cer.sh does not exist or not executable." && exit 1;
  uzh/score_cer.sh --stage 2 --cmd "$cmd" --min_lmwt $lmwt --max_lmwt $lmwt $data $oldlang $outdir
  echo -e "\n### Scoring CER completed ###\n"

  CUR_TIME=$(date +%s)
  echo ""
  echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
  echo ""

  if [[ ! -z $n2d_mapping ]]; then 
    echo -e "\nScoring best paths for F1..."
    uzh/score_f1.sh $outdir $n2d_mapping
    echo -e "\n### Scoring F1 completed ###\n"
  
    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""
  
  else
    echo "Not scoring Scherrer's modified F1 because normalisation-to-dieth mapping not provided."
  fi

else
  echo "Not scoring because requested so..."
fi

CUR_TIME=$(date +%s)
echo ""
echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
echo ""

echo -e "\n### Done $0 ###"
exit 0;

