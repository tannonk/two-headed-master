##############
# Description:
##############
This folder contains the shared code base for the master's projects focusing on ASR for Swiss German.
The scripts are an implementation of a basic ASR framework based on Kaldi and were originally developed by Spitch AG, with the following functionality:

  * Neural networks acoustic model training.
  * WFST lingware compilation.
  * Evaluation.

The Kaldi recipe egs/wsj/s5 (commit 8cc5c8b32a49f8d963702c6be681dcf5a55eeb2e) was used as reference.

###############
# Main scripts:
###############

* train_AM.sh: acoustic models training.
* compile_lingware.sh: lingware compilation.
* decode_nnet.sh: evaluation.

################
# Configuration:
################

* path.sh: script to specify the Kaldi root directory and to add certain directories to the path.
* cmd.sh: script to select the way of running parallel jobs.

##########
# Folders:
##########

* Framework specific:
  - archimob: scripts related to processing the Archimob files.
  - uzh: secondary scripts not included in the Kaldi recipe.
  - manual: manually generated files.
  - install_uzh_server: scripts to install in Ubuntu 16.04 the software needed
    by the framework.
  - doc: documentation files.
* Kaldi:
  - conf: configuration files.
  - local: original recipe-specific files from egs/wsj/s5.
  - utils: utilities shared among all the Kaldi recipes.
  - steps: general scripts related to the different steps followed in the Kaldi
    recipes.

#####################
# ASR PIPELINE 18.10.
#####################

PIPELINE
- XML to .csv: with **archimob/process_exmaralda_xml.py**
- rename audio files and filter those audio files, which do not have corresponding transcription: with **archimob/rename_wavs.py**
- run **train_AM.sh**
- make vocabulary_train.txt: with the script **archimob/create_vocabulary.py**
- run **compile_lingware.sh**
- run **decode_nnet.sh**

Running example with approximate cmds:
1. XML ot .csv
    for train:
    /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/archimob/process_exmaralda_xml.py -i /home/../data/original/train_xml/*.xml -format xml -o /home/../data/processed/train.csv
    for test:
    /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/archimob/process_exmaralda_xml.py -i /home/../data/original/test_xml/*.xml -format xml -o /home/../data/processed/test.csv
2. rename chunked wavs
    for train:
    /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/archimob/rename_wavs.py -i /home/.../data/processed/train.csv -chw /home/.../data/processed/wav_train/
    for test:
    /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/archimob/rename_wavs.py -i /home/.../data/processed/test.csv -chw /home/.../data/processed/wav_test/
3. Training AM
    nohup /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/train_AM.sh /home/.../data/processed/train.csv /home/.../data/processed/wav_train /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/out_AM
4. Create vocabulary
    /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/archimob/create_vocabulary.py -i /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/out_AM/initial_data/ling/lexicon.txt -o /home/.../data/processed/vocabulary_train.txt
5. Lingware (no need of nohup actually, as it is fast...)
    nohup /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/compile_lingware.sh out_AM/initial_data/ling /home/.../data/processed/vocabulary_train.txt /home/.../data/processed/language_model/language_model.arpa out_AM/models/discriminative/nnet_disc out_ling
6. Decoding
    nohup /home/.../kaldi_wrk_dir/spitch_kaldi_UZH/decode_nnet.sh /home/.../data/processed/test.csv /home/.../data/processed/wav_test out_AM/models/discriminative/nnet_disc out_ling out_decode




# **CHANGES**

### 1) Preprocess the transcriptions
**archimob/process_exmaralda_xml.py**
WHAT: A new argument, which defines the format of the input (EXB or XML) was introduced: --input-format (-format).
OLD:
input: mandatory input is transcription files in EXB (Exmaralda) format
output: .csv built with the data from transcriptions: [utt_id, transcription, speaker_id, duration, speech-in-speech, no-relevant-speech]

##### to process exmaralda (.exb) and audio (.wav) files
*archimob/process_exmaralda_xml.py -i data/original/all_exb/*.exb -w original/all_wav/ -o train.csv -O wav_train

NEW:
A new argument is introduced: --input-format (-format), which allows the choice of the input EXB or XML formats.
input:  a) -format exb transcription files in EXB (Exmaralda) format — the same as in the old version     (is still default!!).
  b) -format xml transcription files in XML format.
output: a) for EXB, the same .csv output as in the old version
  b) for XML, .csv contains the following info: [utt_id, transcription, normalized, speaker_id, audio_id, anonymity, speech_in_speech, missing_audio, no-relevant-speech]

##### to process Exmaralda files (.exb)
archimob/process_exmaralda_xml.py -i data/ArchiMob/EXB/*.exb -format exb -o train.csv

##### to process XML files (.xml)
archimob/process_exmaralda_xml.py -i data/ArchiMob/XML/test/*.xml -format xml -o train.csv

NOTE: to switch from the original transcription to the normalised one, make change in “archimob/prepare_Archimob_training_files.sh”: line 100:
$scripts_dir/process_archimob_csv.py -i $input_csv -transcr original -f -p \
                     -t $output_trans -s $spn_word -n $sil_word -o $output_lst

FILES THAT HAVE BEEN CHANGED for this step:
process_exmaralda_xml.py
archimob_chunk.py
archimob/prepare_Archimob_training_files.sh
process_archimob_csv.py

IMPORTANT
The script now also includes 4 columns, which enable the further filtering. Filtering criteria are:
anonymity, speech_in_speech, missing_audio, no-relevant-speech
‘missing_audio’ is filled during the renaming step by the **renaming_wavs.py** including the cases when audio file is present but is empty. The other three filtering criteria are already filled at this step (with the information available from XML).

### 2) Rename chunked wav files (new script)
**archimob/rename_wavs.py**
  — renames chunked .wav files in accordance with their transcriptions. Information about the alignment between audio files and transcriptions is taken from .csv [audio_id] (in XML "media-pointer" information)
  To run:
  archimob/rename_wavs.py -i input_csv -chw dir_with_chunked_wavs

### 3) Make vocabulary
**archimob/create_vocabulary.py**
  — creates vocabulary_train.txt file, which is used at the LINGWARE step (Language Model), based on the lexicon.txt file (created during the training step).
  To run:
  archimob/create_vocabulary.py -i out_AM/initial_data/ling/lexicon.txt -o data/processed/vocabulary_train_43.txt

### 4) Decoding
The script changed: **decode_nnet.sh**
WHAT: instead of references.txt the input argument was modified to be .csv test file (created in the same way as train.csv with **archimob/process_exmaralda_xml.py**)
OLD: decode_nnet.sh takes the references.txt, a file with a list of all test transcriptions and corresponding IDs, as one of its input arguments.

NEW: Not to create the references.txt file manually before the decoding is run, the decode_nnet.sh was modified. Now as an input argument, which would contain test transcription info, .csv test file instead of references.txt is taken (.csv for test data is created woth the same script that is used for .csv train file: archimob/process_exmaralda_xml.py).
input: .csv as the first argument; other arguments stay unchanged.

