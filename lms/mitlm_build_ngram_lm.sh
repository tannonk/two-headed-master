#!/bin/bash

set -u

# This script creates an arpa language model with the MIT toolkit using as
# input a OSPL corpus.
#
# To call:
#   bash ./mitlm_build_ngram_lm.sh [order] [test_file] input_file output_lm
#
# Example call:
#   bash ./mitlm_build_ngram_lm.sh \
#   -o 3 \
#   -t /home/tannon/processed/test_files/test.csv \
#   archimob_noah.txt \
#   lms/archi_noah.arpa
#
# Optional parameters:
# -o language model order
# -t test_file (should be a one-sentence-per-line text file)

################
# Configuration:
################
lm_order=3
test_file=

echo $0 $@
while getopts 'o:t:h' option; do
    case $option in
	o)
	    lm_order=${OPTARG}
	    ;;
  t)
      test_file=${OPTARG}
	    ;;
  h)
	    echo "$0 [-o lm_order] [-t test_file] input_file output_dir"
	    exit 0
	    ;;
	\?)
	    echo "Option not supported: -$OPTARG" >$2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
    esac
done
shift $((OPTIND-1))

if [[ $# -ne 2 ]]; then
    echo "Wrong call. Should be: $0 [-o lm_order] input_file output_lm"
    exit 1
fi

############
# arguments:
############
input_file=$1
out_lm=$2

# Check whether ffmpeg is installed:
type estimate-ngram &> /dev/null
[[ $? -ne 0 ]] && echo 'Error: the MIT toolkit is not installed' && exit 1

for f in $input_file; do
    [[ ! -e $f ]] && echo "Error: missing file $f" && exit 1
done

#  Create the language model:
echo "Creating the language model: $out_lm"

estimate-ngram -t $input_file -o $lm_order -wl $out_lm

[[ $? -ne 0 ]] && echo 'Error calling estimate-ngram' && exit 1

# Evaluate the lm for perplexity

if [[ ! -z $test_file ]] && [[ ! -e $test_file ]]; do
  echo "Scoring perplexity for $out_lm on $test_file"
  evaluate-ngram -l $out_lm -o $lm_order -ep $test_file
done

echo "Done: $0"
