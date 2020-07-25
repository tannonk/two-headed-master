##############
## baseline archimob_r2
##############

DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r2/char
AUDIO := /mnt/data/archimob_r2/chunked_wav_files
TRAIN_CSV := /mnt/tannon/corpus_data/csv_files/diacritics_norm/train.csv
DEV_CSV := /mnt/tannon/corpus_data/csv_files/diacritics_norm/dev.csv
TEST_CSV := /mnt/tannon/corpus_data/csv_files/diacritics_norm/test.csv

########################
## check data splits
########################

validate_input_files:
	python3 $(DEV)/archimob/validation/validate_orig_norm.py $(TRAIN_CSV)
	python3 $(DEV)/archimob/validation/validate_orig_norm.py $(DEV_CSV)
	python3 $(DEV)/archimob/validation/validate_orig_norm.py $(TEST_CSV)
	python3 $(DEV)/archimob/validation/validate_csv.py $(TRAIN_CSV) $(AUDIO)
	python3 $(DEV)/archimob/validation/validate_csv.py $(DEV_CSV) $(AUDIO)
	python3 $(DEV)/archimob/validation/validate_csv.py $(TEST_CSV) $(AUDIO)
	python3 $(DEV)/archimob/validation/validate_splits.py $(TRAIN_CSV) $(TEST_CSV)
	python3 $(DEV)/archimob/validation/validate_splits.py $(TRAIN_CSV) $(DEV_CSV)
	python3 $(DEV)/archimob/validation/validate_splits.py $(DEV_CSV) $(TEST_CSV)

########################
## train acoustic models
########################

#TODO

train_am:
	mkdir -p $(OUT_DIR)/am_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	./train_AM.sh \
	--num_jobs 16 \
	$(TRAIN_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	> $(OUT_DIR)/am_out/am.log &

#######################################
## build HCLG.fst and decode on dev set
#######################################

#TODO

# baseline: /mnt/tannon/lms/archimob2_orig_3gram.arpa
baseline: /mnt/tannon/corpus_data/csv_files/diacritics_norm/mitlm_3gram_word.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	/mnt/tannon/corpus_data/csv_files/diacritics_norm/norm2dieth_mapping.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

####################################
## decode on test set for evaluation
####################################

evaluate_baseline:
	mkdir -p $(OUT_DIR)/baseline/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/baseline/lw_out/ \
	$(OUT_DIR)/baseline/eval_out/ \
	13 \
	orig \
	/mnt/tannon/corpus_data/csv_files/diacritics_norm/norm2dieth_mapping.json \
	> $(OUT_DIR)/baseline/eval_out/eval.log&

#####################################

graph_9gram: /mnt/tannon/corpus_data/csv_files/diacritics_norm/mitlm_3gram_char.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode_char.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	/mnt/tannon/corpus_data/csv_files/diacritics_norm/norm2dieth_mapping.json \
	$(OUT_DIR)/am_out/initial_data/ling/nonsilence_phones.txt \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_graph_9gram:
	mkdir -p $(OUT_DIR)/graph_9gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate_char.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/graph_9gram/lw_out/ \
	$(OUT_DIR)/graph_9gram/eval_out/ \
	7 \
	orig \
	/mnt/tannon/corpus_data/csv_files/diacritics_norm/norm2dieth_mapping.json \
	> $(OUT_DIR)/graph_9gram/eval_out/eval.log&