
# Description:

This branch contains the working code for the master's project focusing on language representation and modelling for Swiss German ASR (2019/2020).

The scripts are an implementation of a basic ASR framework based on Kaldi and were originally developed by Spitch AG, with the following functionality:

- Neural networks acoustic model training.
- WFST lingware compilation.
- Evaluation.

The Kaldi (version 5.5.) recipe egs/wsj/s5 (commit 8cc5c8b32a49f8d963702c6be681dcf5a55eeb2e) was used as reference.

# Main scripts:

`run_archimob.sh`
	- data preparation
	- acoustic models training

```
run_archimob.sh <archimob_input_csv> <archimob_wav_files_directory> <am_output_directory> <transcription_type> <pronunciation_lexicon>
```

`compile_and_decode.sh`
	- lingware compilation and validation

```
compile_and_decode.sh <arpa_lm> <am_output_directory> <archimob_dev_csv> <archimob_wav_files_directory> <lw_output_directory> <transcription_type> <lmwt_params> <flexwer_mapping>
```

`evaluate.sh`
	- test set decoding and evaluation

```
./evaluate.sh <archimob_test_csv> <archimob_wav_files_directory> <am_output_directory> <lw_output_directory> <eval_output_directory> <lmwt> <transcription_type> <flexwer_mapping>
```

# Configuration:

`path.sh`
	- script to specify the Kaldi root directory and to add certain directories to the path.

`cmd.sh`
	- script to select the way of running parallel jobs.

# Folders:

Framework specific:

`archimob`
	- scripts related to processing the Archimob files for word-level modelling.

`archimob_char`
	- scripts related to processing the Archimob files for character-level modelling.

`uzh`
	- secondary scripts not included in the Kaldi recipe.

`manual`
	- manually generated files.

`doc`
 	- documentation files.

`lms`
	- scripts for compiling language models

`scripts`
	- small scripts for processing different parts of ArchiMob and Kaldi outputs

`experiments`
	- Makefiles containing commands for exectuing experiments (e.g. training AMs, compiling WFSTs and evaluating)

Kaldi:

`conf`
	- configuration files.
`local`
	- original recipe-specific files from egs/wsj/s5.
`utils`
	- utilities shared among all the Kaldi recipes.
`steps`
	- general scripts related to the different steps followed in the Kaldi recipes.

---

# Steps for running experiment on dialectial (Dieth) transcriptions

1. To generate original lexicon from a csv file:

First, extract Dieth transcription utterances from train.csv (possibly also dev.csv/test.csv)

```
python ./archimob/process_archimob_csv.py \
-i ../data/archimob_r2/train.csv \
-trans orig \
-t ../processed/dieth/dieth_trans.txt
```

Then create lexicon by mapping grapheme clusters to phones symbols (according to Fran's original approach)

```
python ./archimob/create_simple_lexicon.py \
-v ../processed/dieth/dieth_trans.txt \
-c manual/clusters.txt \
-o ../processed/dieth/dieth_lexicon.txt
```

2. Train AMs

```
bash ./run_archimob.sh \
../data/archimob_r2/train.csv \
../data/archimob_r2/chunked_wav_files \
../processed/dieth/am_out \
'orig' \
../processed/dieth/dieth_lexicon.txt
```

3. Compile WFST and decode on validation set to get best WIP and LMWT

NB. This step assumes a pre-computed LM in .arpa format (as produced by SRILM/MITLM), e.g., `../lms/dieth/mitlm_mkn_3.arpa`.
NB. If mapping of normalised to dieth wordforms is available, include it as the last argument for computing FlexWER.

```
bash ./compile_and_decode.sh \
../lms/dieth/mitlm_mkn_3.arpa \
../processed/dieth/am_out \
../data/archimob_r2/dev.csv \
../data/archimob_r2/chunked_wav_files \
../processed/dieth/lw_out/ \
orig \
"--min-lmwt 5 --max-lmwt 20" \
../data/archimob_r2/norm2dieth_clean.json
```

4. Decoding test set and evaluating performance

NB. Specify best LMWT according to validation set decoding explicitly (in this example, `11`)
NB. If mapping of normalised to dieth wordforms is available, include it as the last argument for computing FlexWER.

```
bash ./evaluate.sh \
../data/archimob_r2/test.csv \
../data/archimob_r2/chunked_wav_files \
../processed/dieth/am_out \
../processed/dieth/lw_out/ \
../processed/dieth/eval_out/ \
11 \
orig \
../data/archimob_r2/norm2dieth_clean.json
```

----

# Steps for running experiment on normaliased transcriptions

Steps are largely the same as above. The main difference is occurs in the lexicon generation and training language model. For all basic commands, the <transcription_type> argument should be `norm` rather than `orig`.

Useful tips for working with normalised transcriptions:
- ensure that the csv has been normalised to remove unwanted diacrtitics (e.g. 'õ', 'ã', etc.) 
- ensure that input lexicon has been extended to cover as many in-vocabulary words as possible

Example call for AM training:

```
bash ./run_archimob.sh \
../data/archimob_r2/train.csv \
../data/archimob_r2/chunked_wav_files \
../norm/am_out \
'norm' \
../processed/norm/extended_lexicon.txt
```

---

Updated 25/07/2020
