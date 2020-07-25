##############
## baseline archimob_r2
##############

DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r2/sampa
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

# train_am:
# 	mkdir -p $(OUT_DIR)/am_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	./train_norm_AM.sh \
# 	--num_jobs 16 \
# 	$(TRAIN_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	norm \
# 	/mnt/tannon/corpus_data/norm2sampa_zrh.json \
# 	> $(OUT_DIR)/am_out/am.log &

#######################################
## build HCLG.fst and decode on dev set
#######################################

compile_baseline: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_3.arpa
	mkdir -p $(OUT_DIR)/baseline/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/baseline/lw_out/ \
	norm \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR)/baseline/lw_out/lw.log&


evaluate_baseline:
	mkdir -p $(OUT_DIR)/baseline/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/baseline/lw_out/ \
	$(OUT_DIR)/baseline/eval_out/ \
	11 \
	norm \
	> $(OUT_DIR)/baseline/eval_out/eval.log&

######################################

mitlm_mkn_5gram: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_5.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR)/$@/lw_out/lw.log&


evaluate_mitlm_mkn_5gram:
	mkdir -p $(OUT_DIR)/mitlm_mkn_5gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/mitlm_mkn_5gram/lw_out/ \
	$(OUT_DIR)/mitlm_mkn_5gram/eval_out/ \
	11 \
	norm \
	> $(OUT_DIR)/mitlm_mkn_5gram/eval_out/eval.log&


######################################

mitlm_mkn_open_tuned_5gram: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_open_tuned_5.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR)/$@/lw_out/lw.log&


evaluate_mitlm_mkn_open_tuned_5gram:
	mkdir -p $(OUT_DIR)/mitlm_mkn_open_tuned_5gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/mitlm_mkn_open_tuned_5gram/lw_out/ \
	$(OUT_DIR)/mitlm_mkn_open_tuned_5gram/eval_out/ \
	8 \
	norm \
	> $(OUT_DIR)/mitlm_mkn_open_tuned_5gram/eval_out/eval.log&


##################################

# /mnt/tannon/lms/oov_data/norm/lms/1M_open_mkn3.arpa
# /mnt/tannon/lms/incremental_training_data/norm/norm_lrg_3gram.arpa

norm_lrg_3gram: /mnt/tannon/lms/oov_data/norm/lms/1M_open_mkn3.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 7 --max-lmwt 17" \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_norm_lrg_3gram:
	mkdir -p $(OUT_DIR)/norm_lrg_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/norm_lrg_3gram/lw_out/ \
	$(OUT_DIR)/norm_lrg_3gram/eval_out/ \
	10 \
	norm \
	> $(OUT_DIR)/norm_lrg_3gram/eval_out/eval.log&


##################################

norm_int_lrg_3gram: /mnt/tannon/lms/interp_models/norm/norm_interpolated.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_norm_int_lrg_3gram:
	mkdir -p $(OUT_DIR)/norm_int_lrg_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/norm_int_lrg_3gram/lw_out/ \
	$(OUT_DIR)/norm_int_lrg_3gram/eval_out/ \
	12 \
	norm \
	> $(OUT_DIR)/norm_int_lrg_3gram/eval_out/eval.log&


##############################

ood_open_80000_mkn3: /mnt/tannon/lms/oov_data/norm/lms/80000_open_mkn3.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 7 --max-lmwt 17" \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_ood_open_80000_mkn3:
	mkdir -p $(OUT_DIR)/ood_open_80000_mkn3/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/ood_open_80000_mkn3/lw_out/ \
	$(OUT_DIR)/ood_open_80000_mkn3/eval_out/ \
	8 \
	norm \
	> $(OUT_DIR)/ood_open_80000_mkn3/eval_out/eval.log&

##############################

ood_open_80000_mkn5: /mnt/tannon/lms/oov_data/norm/lms/80000_open_mkn5.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 7 --max-lmwt 17" \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_ood_open_80000_mkn5:
	mkdir -p $(OUT_DIR)/ood_open_80000_mkn5/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/ood_open_80000_mkn5/lw_out/ \
	$(OUT_DIR)/ood_open_80000_mkn5/eval_out/ \
	8 \
	norm \
	> $(OUT_DIR)/ood_open_80000_mkn5/eval_out/eval.log&

#####################################

int_mitlm_open_DTTO_3gram: /mnt/tannon/lms/interp_models_2/norm/intlms/MITLM_OPEN_norm_tueba_tatoeba_opensub.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	norm \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR)/$@/lw_out/lw.log&


evaluate_int_mitlm_open_DTTO_3gram:
	mkdir -p $(OUT_DIR)/int_mitlm_open_DTTO_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/int_mitlm_open_DTTO_3gram/lw_out/ \
	$(OUT_DIR)/int_mitlm_open_DTTO_3gram/eval_out/ \
	11 \
	norm \
	> $(OUT_DIR)/int_mitlm_open_DTTO_3gram/eval_out/eval.log&


##############################
## 2-gram LM
###############################

compile_with_2gram: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_open_tuned_2.arpa
	mkdir -p $(OUT_DIR)/2gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/2gram/lw_out/ \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	> $(OUT_DIR)/2gram/lw_out/lw.log&

evaluate_with_2gram: $(OUT_DIR)/2gram
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$</lw_out/ \
	$</eval_out/ \
	11 \
	norm \
	> $</eval_out/eval.log&


##############################
## 3-gram LM
###############################

compile_with_3gram: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_open_tuned_3.arpa
	mkdir -p $(OUT_DIR)/3gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/3gram/lw_out/ \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	> $(OUT_DIR)/3gram/lw_out/lw.log&

evaluate_with_3gram: $(OUT_DIR)/3gram
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$</lw_out/ \
	$</eval_out/ \
	11 \
	norm \
	> $</eval_out/eval.log&


##########################
## 4-gram LM
##########################

compile_with_4gram: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_open_tuned_4.arpa
	mkdir -p $(OUT_DIR)/4gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/4gram/lw_out/ \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	> $(OUT_DIR)/4gram/lw_out/lw.log&


evaluate_with_4gram: $(OUT_DIR)/4gram
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$</lw_out/ \
	$</eval_out/ \
	11 \
	norm \
	> $</eval_out/eval.log&

###############################
## 5-gram LM
###############################

compile_with_5gram: /mnt/tannon/lms/stat_ngram_exp/norm/mitlm/mitlm_mkn_open_tuned_5.arpa
	mkdir -p $(OUT_DIR)/5gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/5gram/lw_out/ \
	norm \
	"--min-lmwt 1 --max-lmwt 20" \
	> $(OUT_DIR)/5gram/lw_out/lw.log&

evaluate_with_5gram: $(OUT_DIR)/5gram
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$</lw_out/ \
	$</eval_out/ \
	12 \
	norm \
	> $</eval_out/eval.log&



###########################
## g2p lexicon
###########################

train_g2p_extended_am:
	mkdir -p /mnt/tannon/processed/archimob_r2/sampa2/am_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	./train_norm_AM.sh \
	--num_jobs 16 \
	/mnt/tannon/g2p_exp/normalised_train_a2.csv \
	$(AUDIO) \
	/mnt/tannon/processed/archimob_r2/sampa2/am_out \
	norm \
	/mnt/tannon/g2p_exp/data/lexicon_norm2sampa_zrh_normalised.json \
	> /mnt/tannon/processed/archimob_r2/sampa2/am_out/am.log &

# /mnt/tannon/g2p_exp/data/lexicon_norm2sampa_zrh_normalised.json
# /mnt/tannon/g2p_exp/normalised_dev_a2.csv
# /mnt/tannon/g2p_exp/normalised_test_a2.csv
# /mnt/tannon/g2p_exp/normalised_train_a2.csv

compile_g2p_extended: /mnt/tannon/g2p_exp/lm/mkn_5gram_open.arpa
	mkdir -p /mnt/tannon/processed/archimob_r2/sampa2/5gram_open/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	/mnt/tannon/processed/archimob_r2/sampa2/am_out \
	/mnt/tannon/g2p_exp/normalised_dev_a2.csv \
	$(AUDIO) \
	/mnt/tannon/processed/archimob_r2/sampa2/5gram_open/lw_out/ \
	norm \
	"--min-lmwt 5 --max-lmwt 20" \
	> /mnt/tannon/processed/archimob_r2/sampa2/5gram_open/lw_out/lw.log&
	
evaluate_g2p_extended: /mnt/tannon/processed/archimob_r2/sampa2/5gram_open/
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	/mnt/tannon/g2p_exp/normalised_test_a2.csv \
	$(AUDIO) \
	/mnt/tannon/processed/archimob_r2/sampa2/am_out \
	$</lw_out/ \
	$</eval_out/ \
	12 \
	norm \
	> $</eval_out/eval.log&