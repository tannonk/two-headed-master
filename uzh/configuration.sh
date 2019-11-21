#!/bin/bash

#
# Configuration script with certain variables needed both for training and
# lingware generation
#

# Graphemic clusters for the pronunciations:
export GRAPHEMIC_CLUSTERS='manual/clusters.txt'
# Word to represent general speech events (like words without pronunciations,
# hesitations, truncations, ...)
export SPOKEN_NOISE_WORD='<SPOKEN_NOISE>'
# Word to represent silence and non-speech events (breathing, short noises
# without a speech like spectrum, ...)
export SIL_WORD='<SIL_WORD>'
# Word to represent non-speech events (coughing, laughter, etc
# without a speech like spectrum, ...)
export NOISE_WORD='<NOISE>'
# Word to represent OOV words
# export UNK_WORD='<UNK>'
