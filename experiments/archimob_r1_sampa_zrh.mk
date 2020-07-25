##############
## Archimob r1 STNT (SAMPA)
##############

## data preparation
DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r1/zrh_sampa
AUDIO := /mnt/data/archimob_r2/chunked_wav_files
TRAIN_CSV := /mnt/tannon/corpus_data/csv_files/archimob_r1/train.csv
DEV_CSV := /mnt/tannon/corpus_data/csv_files/archimob_r1/dev.csv
TEST_CSV := /mnt/tannon/corpus_data/csv_files/test_files/test.csv
PRON := /mnt/tannon/corpus_data/norm2sampa_zrh.json

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


####################################
## steps for ZRH sampa
####################################

# train_am:
# 	mkdir -p $(OUT_DIR)/am_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	./train_norm_AM.sh \
# 	--num_jobs 40 \
# 	$(TRAIN_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	norm \
# 	$(PRON) \
# 	> $(OUT_DIR)/am_out/am.log &


compile_baseline: $(OUT_DIR)
	mkdir -p $</lw_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	/mnt/tannon/lms/archimob1_norm_3gram.arpa \
	$</am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$</lw_out \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	> $</lw_out/lw.log &


evaluate_baseline: $(OUT_DIR)
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$</am_out \
	$</lw_out/ \
	$</eval_out/ \
	11 \
	norm \
	> $</eval_out/eval.log &

#############################
##
#############################

# compile_system_with_archimob2_lm: /mnt/tannon/lms/archimob2_norm_3gram.arpa
# 	mkdir -p $(OUT_DIR)/archimob2_lm/lw_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/archimob2_lm/lw_out \
# 	norm \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	> $(OUT_DIR)/archimob2_lm/lw_out/lw.log &

# evaluate_system_with_archimob2_lm:
# 	mkdir -p $(OUT_DIR)/archimob2_lm/eval_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$(OUT_DIR)/archimob2_lm/lw_out \
# 	$(OUT_DIR)/archimob2_lm/eval_out \
# 	11 \
# 	norm \
# 	> $(OUT_DIR)/archimob2_lm/eval_out/eval.log &
