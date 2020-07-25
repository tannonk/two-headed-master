SCRIPTS_DIR := /home/tannon/kaldi_wrk/two-headed-master
LM_DIR := /mnt/tannon/lms
CSV_FILES := /mnt/tannon/corpus_data/csv_files
GSW_DATA := /mnt/tannon/corpus_data/gsw_data
ORIG_TEST := /mnt/tannon/corpus_data/csv_files/test_files/test_orig_utt.txt
NORM_TEST := /mnt/tannon/corpus_data/csv_files/test_files/test_norm_utt.txt
LOG := /mnt/tannon/lms/lm.log


##########################
## Initial data processing
##########################



create_archimob_r1_orig_utterance_files:
# extract utterances from train.csv and dev.csv with modified process_archimob_csv.py
# original transcription
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r1/train.csv \
	-trans orig -p \
	-t $(CSV_FILES)/archimob_r1/train_orig_utt.txt
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r1/dev.csv \
	-trans orig -p \
	-t $(CSV_FILES)/archimob_r1/dev_orig_utt.txt



create_archimob_r1_norm_utterance_files:
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r1/train.csv \
	-trans norm -p \
	-t $(CSV_FILES)/archimob_r1/train_norm_utt.txt
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r1/dev.csv \
	-trans norm -p \
	-t $(CSV_FILES)/archimob_r1/dev_norm_utt.txt



create_archimob_r2_orig_utterance_files:
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r2/train.csv \
	-trans orig -p \
	-t $(CSV_FILES)/archimob_r2/train_orig_utt.txt
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r2/dev.csv \
	-trans orig -p \
	-t $(CSV_FILES)/archimob_r2/dev_orig_utt.txt



create_archimob_r2_norm_utterance_files:
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r2/train.csv \
	-trans norm -p \
	-t $(CSV_FILES)/archimob_r2/train_norm_utt.txt
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/archimob_r2/dev.csv \
	-trans norm -p \
	-t $(CSV_FILES)/archimob_r2/dev_norm_utt.txt



create_test_orig_utterance_files:
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/test_files/test.csv \
	-trans orig -p \
	-t $(CSV_FILES)/test_files/test_orig_utt.txt



create_test_norm_utterance_files:
	python $(SCRIPTS_DIR)/archimob/process_archimob_csv.py \
	-i $(CSV_FILES)/test_files/test.csv \
	-trans norm -p \
	-t $(CSV_FILES)/test_files/test_norm_utt.txt

########################
## Archimob 1
########################



archimob1_orig_3gram: $(CSV_FILES)/archimob_r1/train_orig_utt.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r1/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob1_orig_3gram_limited_vocab: $(CSV_FILES)/archimob_r1/train_orig_utt.txt /mnt/tannon/processed/archimob_r1/orig/am_out/initial_data/tmp/vocabulary.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-vocab /mnt/tannon/processed/archimob_r1/orig/am_out/initial_data/tmp/vocabulary.txt \
	-unk true \
	-opt-perp $(CSV_FILES)/archimob_r1/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1

########################
## Archimob 2
########################


archimob2_orig_3gram: $(CSV_FILES)/archimob_r2/train_orig_utt.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
#Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_orig_3gram_limited_vocab: $(CSV_FILES)/archimob_r2/train_orig_utt.txt /mnt/tannon/processed/archimob_r2/orig/am_out/initial_data/tmp/vocabulary.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-vocab /mnt/tannon/processed/archimob_r2/orig/am_out/initial_data/tmp/vocabulary.txt \
	-unk true \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_orig_noah_3gram: $(CSV_FILES)/archimob_r2/train_orig_utt.txt $(GSW_DATA)/NOAH_sentences/noah_norm.txt
	cat $^ > $(GSW_DATA)/archimob_noah.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $(GSW_DATA)/archimob_noah.txt >> $(LOG) 2>&1
	@wc -l $(GSW_DATA)/archimob_noah.txt >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $(GSW_DATA)/archimob_noah.txt \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_orig_noah_lcc_3gram: $(CSV_FILES)/archimob_r2/train_orig_utt.txt $(GSW_DATA)/NOAH_sentences/noah_norm.txt $(GSW_DATA)/LCC/ch_web_2017.norm.txt
	cat $^ > $(GSW_DATA)/archimob_noah_lcc.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $(GSW_DATA)/archimob_noah_lcc.txt >> $(LOG) 2>&1
	@wc -l $(GSW_DATA)/archimob_noah_lcc.txt >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $(GSW_DATA)/archimob_noah_lcc.txt \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_orig_gsw_transcriptions_3gram: $(CSV_FILES)/archimob_r2/train_orig_utt.txt $(GSW_DATA)/Transcripts_Phonogrammarchiv/transcripts_phonogrammarchiv.txt $(GSW_DATA)/Transcripts_Schawinski/transcripts_schawinski.txt
	cat $^ > $(GSW_DATA)/archimob_transcripts.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
#Build lm
	estimate-ngram \
	-t $(GSW_DATA)/archimob_transcripts.txt \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1

###########################
# normalised transcriptions
###########################



archimob1_norm_3gram: $(CSV_FILES)/archimob_r1/train_norm_utt.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_norm_3gram: $(CSV_FILES)/archimob_r2/train_norm_utt.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1


archimob1_norm_3gram_limited_vocab: $(CSV_FILES)/archimob_r1/train_norm_utt.txt /mnt/tannon/processed/archimob_r1/norm/am_out/initial_data/tmp/vocabulary.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-vocab /mnt/tannon/processed/archimob_r1/norm/am_out/initial_data/tmp/vocabulary.txt \
	-unk true \
	-opt-perp $(CSV_FILES)/archimob_r1/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_norm_3gram_limited_vocab: $(CSV_FILES)/archimob_r2/train_norm_utt.txt /mnt/tannon/processed/archimob_r2/norm/am_out/initial_data/tmp/vocabulary.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $< \
	-o 3 \
	-vocab /mnt/tannon/processed/archimob_r2/norm/am_out/initial_data/tmp/vocabulary.txt \
	-unk true \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1

archimob2_norm_noah_3gram: $(CSV_FILES)/archimob_r2/train_norm_utt.txt $(GSW_DATA)/NOAH_sentences/noah_norm.txt
	cat $^ > $(GSW_DATA)/archimob_noah_norm.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $(GSW_DATA)/archimob_noah_norm.txt >> $(LOG) 2>&1
	@wc -l $(GSW_DATA)/archimob_noah_norm.txt >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $(GSW_DATA)/archimob_noah_norm.txt \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1



archimob2_norm_noah_lcc_3gram: $(CSV_FILES)/archimob_r2/train_norm_utt.txt $(GSW_DATA)/NOAH_sentences/noah_norm.txt $(GSW_DATA)/LCC/ch_web_2017.norm.txt
	cat $^ > $(GSW_DATA)/archimob_noah_lcc_norm.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $(GSW_DATA)/archimob_noah_lcc_norm.txt >> $(LOG) 2>&1
	@wc -l $(GSW_DATA)/archimob_noah_lcc_norm.txt >> $(LOG) 2>&1
# Build lm
	estimate-ngram \
	-t $(GSW_DATA)/archimob_noah_lcc_norm.txt \
	-o 3 \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-wl $(LM_DIR)/$@.arpa >> $(LOG) 2>&1









##############

interpolated_large_3gram_orig: /mnt/tannon/lms/archimob2_orig_3gram.arpa /mnt/tannon/lms/added_gsw_data
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	interpolate-ngram \
	-lm /mnt/tannon/lms/archimob2_orig_3gram.arpa,/mnt/tannon/lms/added_gsw_data/ch-web_3gram.arpa,/mnt/tannon/lms/added_gsw_data/noah_3gram.arpa,/mnt/tannon/lms/added_gsw_data/phonogramarchiv_3gram.arpa,/mnt/tannon/lms/added_gsw_data/schawinski_3gram.arpa \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-write-lm $(LM_DIR)/added_gsw_data/$@.arpa >> $(LOG) 2>&1



interpolated_large_3gram_orig_closed: /mnt/tannon/lms/archimob2_orig_3gram_limited_vocab.arpa /mnt/tannon/lms/added_gsw_data
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	interpolate-ngram \
	-lm /mnt/tannon/lms/archimob2_orig_3gram_limited_vocab.arpa,/mnt/tannon/lms/added_gsw_data/ch-web_3gram.arpa,/mnt/tannon/lms/added_gsw_data/noah_3gram.arpa,/mnt/tannon/lms/added_gsw_data/phonogramarchiv_3gram.arpa,/mnt/tannon/lms/added_gsw_data/schawinski_3gram.arpa \
	-unk true \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_orig_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_orig_utt.txt \
	-write-lm $(LM_DIR)/added_gsw_data/$@.arpa >> $(LOG) 2>&1



interpolated_large_3gram_norm: /mnt/tannon/lms/archimob2_norm_3gram.arpa /mnt/tannon/lms/added_gsw_data
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	interpolate-ngram \
	-lm /mnt/tannon/lms/archimob2_norm_3gram.arpa,/mnt/tannon/lms/added_gsw_data/ch-web_3gram.arpa,/mnt/tannon/lms/added_gsw_data/noah_3gram.arpa,/mnt/tannon/lms/added_gsw_data/phonogramarchiv_3gram.arpa,/mnt/tannon/lms/added_gsw_data/schawinski_3gram.arpa \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-write-lm $(LM_DIR)/added_gsw_data/$@.arpa >> $(LOG) 2>&1

### TODO: /mnt/tannon/lms/archimob2_norm_3gram_limited_vocab.arpa
interpolated_large_3gram_norm_closed: /mnt/tannon/lms/archimob2_norm_3gram_limited_vocab.arpa /mnt/tannon/lms/added_gsw_data
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	interpolate-ngram \
	-lm /mnt/tannon/lms/archimob2_norm_3gram_limited_vocab.arpa,/mnt/tannon/lms/added_gsw_data/ch-web_3gram.arpa,/mnt/tannon/lms/added_gsw_data/noah_3gram.arpa,/mnt/tannon/lms/added_gsw_data/phonogramarchiv_3gram.arpa,/mnt/tannon/lms/added_gsw_data/schawinski_3gram.arpa \
	-unk true \
	-opt-perp $(CSV_FILES)/archimob_r2/dev_norm_utt.txt \
	-eval-perp $(CSV_FILES)/test_files/test_norm_utt.txt \
	-write-lm $(LM_DIR)/added_gsw_data/$@.arpa >> $(LOG) 2>&1




###############################
## SRILM
###############################

srilm_orig_3gram_add_0.01: $(CSV_FILES)/archimob_r1/train_orig_utt.txt
# Add stats to log file
	@echo "---" >> $(LOG) 2>&1
	@date >> $(LOG) 2>&1
	@echo $@ >> $(LOG) 2>&1
	@echo $< >> $(LOG) 2>&1
	@wc -l $< >> $(LOG) 2>&1
# Build lm
	ngram-count -order 3 \
	-text $< \
	-addsmooth 0.01 \
	-lm $(LM_DIR)/$@.arpa
# Evaluate the lm for perplexity
	ngram -order 3 \
	-lm trigram-modkn \
	-ppl $(ORIG_TEST) \
	>> $(LOG) 2>&1
