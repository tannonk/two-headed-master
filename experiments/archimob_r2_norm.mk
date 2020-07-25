##############
## baseline archimob_r2
##############

DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r2/norm
AUDIO := /mnt/data/archimob_r2/chunked_wav_files
TRAIN_CSV := /mnt/tannon/corpus_data/csv_files/archimob_r2/train.csv
DEV_CSV := /mnt/tannon/corpus_data/csv_files/archimob_r2/dev.csv
TEST_CSV := /mnt/tannon/corpus_data/csv_files/test_files/test.csv

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

train_am:
	mkdir -p $(OUT_DIR)/am_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	./train_norm_AM.sh \
	--num_jobs 16 \
	$(TRAIN_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	norm \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/am_out/am.log &

#######################################
## build HCLG.fst and decode on dev set
#######################################

compile_system: /mnt/tannon/lms/archimob2_norm_3gram.arpa
	mkdir -p $(OUT_DIR)/baseline/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/baseline/lw_out/ \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/baseline/lw_out/lw.log&

####################################
## decode on test set for evaluation
####################################

evaluate:
	mkdir -p $(OUT_DIR)/baseline/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/baseline/lw_out/ \
	$(OUT_DIR)/baseline/eval_out/ \
	12 \
	norm \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/baseline/eval_out/eval.log&