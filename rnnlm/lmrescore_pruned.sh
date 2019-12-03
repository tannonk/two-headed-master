#!/bin/bash

# Copyright 2017   Hainan Xu
# Apache 2.0

# This script rescores lattices with KALDI RNNLM using a pruned algorithm.
# The details of the algorithm could be found at
# http://www.danielpovey.com/files/2018_icassp_lattice_pruning.pdf
# One example script for this is at egs/swbd/s5c/local/rnnlm/run_lstm.sh


#########
## Config
#########

do_lattice_rescore=1
skip_scoring=false

cmd=run.pl
max_ngram_order=4 # Approximate the lattice-rescoring by limiting the max-ngram-order
                  # if it's set, it merges histories in the lattice if they share
                  # the same ngram history and this prevents the lattice from 
                  # exploding exponentially. Details of the n-gram approximation
                  # method are described in section 2.3 of the paper
                  # http://www.danielpovey.com/files/2018_icassp_lattice_pruning.pdf
max_arcs=         # limit the max arcs in lattice while rescoring. E.g., 20000

acwt=0.1
weight=0.5  # Interpolation weight for RNNLM.
normalize=false # If true, we add a normalization step to the output of the RNNLM
                # so that it adds up to *exactly* 1. Note that this is not necessary
                # as in our RNNLM setup, a properly trained network would automatically
                # have its normalization term close to 1. The details of this
                # could be found at http://www.danielpovey.com/files/2018_icassp_rnnlm.pdf
lattice_prune_beam=8 # Beam used in pruned lattice composition
                     # This option affects speed and how large the composed lattice may be

# End configuration section.

echo "$0 $@"  # Print the command line for logging

. ./utils/parse_options.sh

if [ $# != 5 ]; then
   echo "Does language model rescoring of lattices (remove old LM, add new LM)"
   echo "with Kaldi RNNLM using a pruned algorithm. See comments in file for details"
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

# if provided, F1 is scored using uzh/score_f1.sh, which
# calls uzh/scherrer_eval.py e.g.
# /mnt/tannon/corpus_data/norm2dieth.json
n2d_mapping=${6:-""}

START_TIME=$(date +%s) # record time of operations

echo ""
echo "##################################"
echo "### BEGIN: SETTING CONFIG VARS ###"
echo "##################################"
echo ""

oldlm=$oldlang/G.fst
carpa_option=
if [ ! -f $oldlm ]; then
  echo "$0: file $oldlm not found; looking for $oldlang/G.carpa"
  oldlm=$oldlang/G.carpa
  carpa_option="--use-const-arpa=true"
fi

[ ! -f $oldlm ] && echo "$0: Missing file $oldlm" && exit 1;
[ ! -f $rnnlm_dir/final.raw ] && echo "$0: Missing file $rnnlm_dir/final.raw" && exit 1;
[ ! -f $rnnlm_dir/feat_embedding.final.mat ] && [ ! -f $rnnlm_dir/word_embedding.final.mat ] && echo "$0: Missing word embedding file" && exit 1;

[ ! -f $oldlang/words.txt ] &&\
  echo "$0: Missing file $oldlang/words.txt" && exit 1;
! ls $indir/lat.*.gz >/dev/null &&\
  echo "$0: No lattices input directory $indir" && exit 1;
awk -v n=$0 -v w=$weight 'BEGIN {if (w < 0 || w > 1) {
  print n": Interpolation weight should be in the range of [0, 1]"; exit 1;}}' \
  || exit 1;

if ! head -n -1 $rnnlm_dir/config/words.txt | cmp $oldlang/words.txt -; then
  # the last word of the RNNLM word list is an added <brk> word
  echo "$0: Word lists mismatch for lattices and RNNLM."
  exit 1
fi

# special symbol options file is not empty, fill variable
# with contents, otherwise, set variable explicitly
if [ -s $rnnlm_dir/special_symbol_opts.txt ]; then
    special_symbol_opts=$(cat $rnnlm_dir/special_symbol_opts.txt)
else
    special_symbol_opts="--bos-symbol=1 --eos-symbol=2 --brk-symbol=3"
fi

normalize_opt=
if $normalize; then
  normalize_opt="--normalize-probs=true"
fi
special_symbol_opts=$(cat $rnnlm_dir/special_symbol_opts.txt)

word_embedding=
if [ -f $rnnlm_dir/word_embedding.final.mat ]; then
  word_embedding=$rnnlm_dir/word_embedding.final.mat
else
  word_embedding="'rnnlm-get-word-embedding $rnnlm_dir/word_feats.txt $rnnlm_dir/feat_embedding.final.mat -|'"
fi

max_arcs_opt=
if [ ! -z "$max_arcs" ]; then
  max_arcs_opt="--max-arcs=$max_arcs"
fi

mkdir -p $outdir/log
nj=`cat $indir/num_jobs` || exit 1;
cp $indir/num_jobs $outdir

echo ""
echo "### CONFIGURATION VARIABLES SET AS:"
echo -e "\tCMD: $cmd"
echo -e "\tNUM JOBS: $nj"
echo -e "\tOUTPUT DIR: $outdir"
echo -e "\tOLD LM: $oldlm"
echo -e "\tCARPA OPTION: $carpa_option"
echo -e "\tOLD LM WEIGHT: $oldlm_weight"
echo -e "\tLATTICE PRUNE BEAM: $lattice_prune_beam"
echo -e "\tINTERPOLATION WEIGHT: $weight"
echo -e "\tACOUSTIC WEIGHT: $acwt"
echo -e "\tSPECIAL SYMBOL OPTS: $special_symbol_opts"
echo -e "\tMAX NGRAM ORDER: $max_ngram_order"
echo -e "\tNORMALIZE OPT: $normalize_opt"
echo -e "\tWORD EMBEDDING: $word_embedding"
echo "" 

if [[ $do_lattice_rescore -ne 0 ]]; then

    echo ""
    echo "#################################"
    echo "### BEGIN: RESCORING LATTICES ###"
    echo "#################################"
    echo ""

    echo -e "\tRescoring with lattice-lmrescore-pruned"

    # TODO:
    # incorporate lattice-lmrescore-kaldi-rnnlm-pruned

    # e.g. https://github.com/kaldi-asr/kaldi/blob/master/scripts/rnnlm/lmrescore_pruned.sh
    #   $cmd JOB=1:$nj $outdir/log/rescorelm.JOB.log \
    # lattice-lmrescore-kaldi-rnnlm-pruned --lm-scale=$weight $special_symbol_opts \
    #   --lattice-compose-beam=$lattice_prune_beam \
    #   --acoustic-scale=$acwt --max-ngram-order=$max_ngram_order $normalize_opt $max_arcs_opt \
    #   $carpa_option $oldlm $word_embedding "$rnnlm_dir/final.raw" \
    #   "ark:gunzip -c $indir/lat.JOB.gz|" "ark,t:|gzip -c>$outdir/lat.JOB.gz" || exit 1;
    
    # this is the wrong rescoring for Kaldi RNNLM
    # $cmd JOB=1:$nj $outdir/log/rescorelm.JOB.log \
    #   lattice-lmrescore-pruned --lm-scale=$weight \
    #   $special_symbol_opts \
    #   --lattice-compose-beam=$lattice_prune_beam \
    #   --acoustic-scale=$acwt \
    #   --max-ngram-order=$max_ngram_order \
    #   $normalize_opt \
    #   $max_arcs_opt \
    #   $carpa_option \
    #   $oldlm \
    #   $word_embedding "$rnnlm_dir/final.raw" \
    #   "ark:gunzip -c $indir/lat.JOB.gz|" "ark,t:|gzip -c>$outdir/lat.JOB.gz" || echo "Problem with lattice-lmrescore-pruned" && exit 1;

    CUR_TIME=$(date +%s)
    echo ""
    echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
    echo ""

fi

if ! $skip_scoring ; then

  echo ""
  echo "#####################################"
  echo "### BEGIN: RESCORING WITH METRICS ###"
  echo "#####################################"
  echo ""

  [ ! -x uzh/score.sh ] && echo "Not scoring because uzh/score.sh does not exist or not executable." && exit 1;
  echo -e "\nScoring best paths for WER..."
  uzh/score.sh --cmd "$cmd" $data $oldlang $outdir
  echo -e "\n### Scoring WER completed ###"

  CUR_TIME=$(date +%s)
  echo ""
  echo "TIME ELAPSED: $(($CUR_TIME - $START_TIME)) seconds"
  echo ""

  echo -e "\nScoring best paths for CER..."
  [ ! -x uzh/score_cer.sh ] && echo "Not scoring because uzh/score_cer.sh does not exist or not executable." && exit 1;
  uzh/score_cer.sh --stage 2 --cmd "$cmd" $data $oldlang $outdir
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