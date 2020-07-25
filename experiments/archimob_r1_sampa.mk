##############
## Archimob r1 STNT (SAMPA)
##############

## data preparation
DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r1/sampa
AUDIO := /mnt/data/archimob_r2/chunked_wav_files
TRAIN_CSV := /mnt/tannon/corpus_data/csv_files/archimob_r1/train.csv
DEV_CSV := /mnt/tannon/corpus_data/csv_files/archimob_r1/dev.csv
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
	--num_jobs 40 \
	$(TRAIN_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	norm \
	/mnt/tannon/corpus_data/norm2sampa.json \
	> $(OUT_DIR)/am_out/am.log &


#######################################
## build HCLG.fst and decode on dev set
#######################################

compile_baseline_system:
	mkdir -p $(OUT_DIR)/baseline/lw_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	/mnt/tannon/lms/archimob1_norm_3gram.arpa \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/baseline/lw_out/ \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2sampa.json \
	> $(OUT_DIR)/baseline/lw_out/lw.log &


####################################
## decode on test set for evaluation
####################################

evaluate_baseline:
	mkdir -p $(OUT_DIR)/baseline/eval_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/baseline/lw_out/ \
	$(OUT_DIR)/baseline/eval_out/ \
	10 \
	norm \
	> $(OUT_DIR)/baseline/eval_out/eval.log &


####################################
## steps for ZRH sampa
####################################

train_with_zrh_sampa: $(OUT_DIR)/zrh_sampa/am_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	./train_norm_AM.sh \
	--num_jobs 40 \
	$(TRAIN_CSV) \
	$(AUDIO) \
	$< \
	norm \
	/mnt/tannon/corpus_data/norm2sampa_zrh.json \
	> $</am.log &


compile_system_with_zrh_sampa: $(OUT_DIR)/zrh_sampa/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	/mnt/tannon/lms/archimob1_norm_3gram.arpa \
	$</am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$</lw_out \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2sampa.json \
	> $</lw_out/lw.log &


evaluate_with_zrh_sampa: $(OUT_DIR)/zrh_sampa/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$</am_out \
	$</lw_out/ \
	$</eval_out/ \
	10 \
	norm \
	/mnt/tannon/corpus_data/norm2sampa.json \
	> $</eval_out/eval.log &

#############################
##
#############################

compile_system_with_archimob2_lm: /mnt/tannon/lms/archimob2_norm_3gram.arpa
	mkdir -p $(OUT_DIR)/archimob2_lm/lw_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/archimob2_lm/lw_out \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	> $(OUT_DIR)/archimob2_lm/lw_out/lw.log &

evaluate_system_with_archimob2_lm:
	mkdir -p $(OUT_DIR)/archimob2_lm/eval_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/archimob2_lm/lw_out \
	$(OUT_DIR)/archimob2_lm/eval_out \
	11 \
	norm \
	> $(OUT_DIR)/archimob2_lm/eval_out/eval.log &