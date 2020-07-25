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
`compile_and_decode.sh`
	- lingware compilation and validation
`evaluate.sh`
	- test set decoding and evaluation

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

# Steps for training Dieth-transcription acoustic models

1. Generate original lexicon from a csv file:

	1.1 Extract Dieth transcription utterances from train.csv (possibly also dev.csv/test.csv)

	`cat train.csv dev.csv > train_dev.csv`

	```
	./archimob/process_archimob_csv.py \
	-i /mnt/tannon/processed/testing_comp/orig/train_dev.csv \
	-trans orig \
	-t /mnt/tannon/processed/testing_comp/orig/orig_trans.txt
	```

	1.2 Create lexicon by mapping grapheme clusters to phones symbols (according to Fran's original approach)

	```
	./archimob/create_simple_lexicon.py \
	-v /mnt/tannon/processed/testing_comp/orig/orig_trans.txt \
	-c /home/tannon/kaldi_wrk/two-headed-master/manual/clusters.txt \
	-o /mnt/tannon/processed/testing_comp/orig/orig_lexicon.txt
	```

2. Train AMs

```
bash ./run_archimob.sh \
/mnt/tannon/corpus_data/csv_files/archimob_r2/train.csv \
/mnt/data/archimob_r2/chunked_wav_files \
/mnt/tannon/processed/testing_comp/orig/am_out \
'orig' \
/mnt/tannon/processed/testing_comp/orig/orig_lexicon.txt
```

----

# Steps for training acoustic models on normaliased transcriptions

NB. Ensure that the csv has been normalised to remove unwanted diacrtitics (e.g. 'õ', 'ã', etc.) and ensure that input lexicon has been extended to cover as many in-vocabulary words as possible

To train AMs, use the script `run_archimob.sh` with the following arguments:

```
run_archimob.sh <archimob_input_csv> <archimob_wav_files_directory> <output_directory> <transcription_type> <pronunciation_lexicon>
```

Example call:

```
bash ./run_archimob.sh \
/mnt/tannon/processed/testing_comp/norm/normalised_train_a2.csv \
/mnt/data/archimob_r2/chunked_wav_files \
/mnt/tannon/processed/testing_comp/norm/am_out \
'norm' \
/mnt/tannon/processed/testing_comp/norm/extended_lexicon.txt
```

---
