#!/bin/bash

decode_dir=$1

min_lmwt=100
max_lmwt=0

for f in $decode_dir/wer*; do
    lmwt=`echo $f | cut -d'_' -f2`
    (( $lmwt > $max_lmwt )) && max_lmwt=$lmwt
    (( $lmwt < $min_lmwt )) && min_lmwt=$lmwt
done

echo "$min_lmwt"
echo "$max_lmwt"