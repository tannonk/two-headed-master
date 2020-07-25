##############
## baseline archimob_r2
##############

DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r2/orig
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
# 	./train_AM.sh \
# 	--num_jobs 16 \
# 	$(TRAIN_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	> $(OUT_DIR)/am_out/am.log &

# train_am_2:
# 	mkdir -p /mnt/tannon/processed/archimob_r2/orig2/am_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	./train_AM.sh \
# 	--num_jobs 16 \
# 	$(TRAIN_CSV) \
# 	$(AUDIO) \
# 	/mnt/tannon/processed/archimob_r2/orig2/am_out \
# 	> /mnt/tannon/processed/archimob_r2/orig2/am_out/am.log &

#######################################
## build HCLG.fst and decode on dev set
#######################################



# baseline: /mnt/tannon/lms/archimob2_orig_3gram.arpa
baseline: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_3.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

####################################
## decode on test set for evaluation
####################################

# 13 0.0
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/baseline/eval_out/eval.log&


#####################################

mitlm_mkn_5gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_5.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
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
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/mitlm_mkn_5gram/eval_out/eval.log&


#############################################

# /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa
# /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa

mitlm_mkn_open_tuned_4gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_mitlm_mkn_open_tuned_4gram:
	mkdir -p $(OUT_DIR)/mitlm_mkn_open_tuned_4gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/mitlm_mkn_open_tuned_4gram/lw_out/ \
	$(OUT_DIR)/mitlm_mkn_open_tuned_4gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/mitlm_mkn_open_tuned_4gram/eval_out/eval.log&


#############################################


mitlm_mkn_open_4gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_4.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_mitlm_mkn_open_4gram:
	mkdir -p $(OUT_DIR)/mitlm_mkn_open_4gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/mitlm_mkn_open_4gram/lw_out/ \
	$(OUT_DIR)/mitlm_mkn_open_4gram/eval_out/ \
	11 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/mitlm_mkn_open_4gram/eval_out/eval.log&


###################################################

mitlm_mkn_open_tuned_thresh_4gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4_threshold.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_mitlm_mkn_open_tuned_thresh_4gram:
	mkdir -p $(OUT_DIR)/mitlm_mkn_open_tuned_thresh_4gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/mitlm_mkn_open_tuned_thresh_4gram/lw_out/ \
	$(OUT_DIR)/mitlm_mkn_open_tuned_thresh_4gram/eval_out/ \
	14 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/mitlm_mkn_open_tuned_thresh_4gram/eval_out/eval.log&



##########################################

# /mnt/tannon/lms/incremental_training_data/orig/orig_lrg_3gram.arpa

orig_lrg_3gram: /mnt/tannon/lms/oov_data/orig/lms/all_open_mkn3.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 7 --max-lmwt 17" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_orig_lrg_3gram:
	mkdir -p $(OUT_DIR)/orig_lrg_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/orig_lrg_3gram/lw_out/ \
	$(OUT_DIR)/orig_lrg_3gram/eval_out/ \
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/orig_lrg_3gram/eval_out/eval.log&



########################################

orig_int_lrg_3gram: /mnt/tannon/lms/interp_models/orig/orig_interpolated.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_orig_int_lrg_3gram:
	mkdir -p $(OUT_DIR)/orig_int_lrg_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/orig_int_lrg_3gram/lw_out/ \
	$(OUT_DIR)/orig_int_lrg_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/orig_int_lrg_3gram/eval_out/eval.log&

################################ 31.1.20

int_mitlm_open_DSPNC_3gram: /mnt/tannon/lms/interp_models_2/dieth/intlms/MITLM_OPEN_dieth_schaw_paztek_noah_chweb.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 7 --max-lmwt 17" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_int_mitlm_open_DSPNC_3gram:
	mkdir -p $(OUT_DIR)/int_mitlm_open_DSPNC_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/int_mitlm_open_DSPNC_3gram/lw_out/ \
	$(OUT_DIR)/int_mitlm_open_DSPNC_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/int_mitlm_open_DSPNC_3gram/eval_out/eval.log&



###############################


int_mitlm_open_DWgen_3gram: /mnt/tannon/lms/interp_models_2/dieth/intlms/MITLM_OPEN_dieth_wordgen.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 7 --max-lmwt 17" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_int_mitlm_open_DWgen_3gram:
	mkdir -p $(OUT_DIR)/int_mitlm_open_DWgen_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/int_mitlm_open_DWgen_3gram/lw_out/ \
	$(OUT_DIR)/int_mitlm_open_DWgen_3gram/eval_out/ \
	11 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/int_mitlm_open_DWgen_3gram/eval_out/eval.log&
	
#######################################


int_mitlm_open_DSWgen_3gram: /mnt/tannon/lms/interp_models_2/dieth/intlms/MITLM_OPEN_dieth_chargen.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 7 --max-lmwt 17" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_int_mitlm_open_DSWgen_3gram:
	mkdir -p $(OUT_DIR)/int_mitlm_open_DSWgen_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/int_mitlm_open_DSWgen_3gram/lw_out/ \
	$(OUT_DIR)/int_mitlm_open_DSWgen_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/int_mitlm_open_DSWgen_3gram/eval_out/eval.log&
	

######################################


int_mitlm_open_ALL_3gram: /mnt/tannon/lms/interp_models_2/dieth/intlms/MITLM_OPEN_ALL.arpa
	mkdir -p $(OUT_DIR)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/$@/lw_out/ \
	orig \
	"--min-lmwt 7 --max-lmwt 17" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_int_mitlm_open_ALL_3gram:
	mkdir -p $(OUT_DIR)/int_mitlm_open_ALL_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/int_mitlm_open_ALL_3gram/lw_out/ \
	$(OUT_DIR)/int_mitlm_open_ALL_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/int_mitlm_open_ALL_3gram/eval_out/eval.log&

########################################

orig_small_3gram: /mnt/tannon/lms/incremental_training_data/orig/lms/mkn_3_small.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_orig_small_3gram:
	mkdir -p $(OUT_DIR)/orig_small_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/orig_small_3gram/lw_out/ \
	$(OUT_DIR)/orig_small_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/orig_small_3gram/eval_out/eval.log&


#######################################

orig_rnnlmgen_3gram: /mnt/tannon/lms/interpolated_orig_rnnlmgen_3gram.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_orig_rnnlmgen_3gram:
	mkdir -p $(OUT_DIR)/orig_rnnlmgen_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/orig_rnnlmgen_3gram/lw_out/ \
	$(OUT_DIR)/orig_rnnlmgen_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/orig_rnnlmgen_3gram/eval_out/eval.log&


######################################

orig_rnncharlmgen_3gram: /mnt/tannon/lms/interp_models/interp_orig_rnnlmgen_c2w_3_open.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_orig_rnncharlmgen_3gram:
	mkdir -p $(OUT_DIR)/orig_rnncharlmgen_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/orig_rnncharlmgen_3gram/lw_out/ \
	$(OUT_DIR)/orig_rnncharlmgen_3gram/eval_out/ \
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/orig_rnncharlmgen_3gram/eval_out/eval.log&


######################################

synthetic_word_large_3gram: /mnt/tannon/lms/synthetic_data/orig/word_level/mkn_1000000.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_synthetic_word_large_3gram:
	mkdir -p $(OUT_DIR)/synthetic_word_large_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/synthetic_word_large_3gram/lw_out/ \
	$(OUT_DIR)/synthetic_word_large_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/synthetic_word_large_3gram/eval_out/eval.log&


#######################################


synthetic_char_large_3gram_lex: /mnt/tannon/lms/synthetic_data/orig/char_level/mkn3.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	/mnt/tannon/lms/synthetic_data/orig/char_level/combined_vocabulary.txt \
	> $(OUT_DIR)/$@/lw_out/lw.log&


# todo
evaluate_synthetic_char_large_lex_3gram:
	mkdir -p $(OUT_DIR)/synthetic_char_large_3gram_lex/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/synthetic_char_large_3gram_lex/lw_out/ \
	$(OUT_DIR)/synthetic_char_large_3gram_lex/eval_out/ \
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/synthetic_char_large_3gram_lex/eval_out/eval.log&


#######################################

synthetic_char_large_3gram: /mnt/tannon/lms/synthetic_data/orig/char_level/mkn3.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&


evaluate_synthetic_char_large_3gram:
	mkdir -p $(OUT_DIR)/synthetic_char_large_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/synthetic_char_large_3gram/lw_out/ \
	$(OUT_DIR)/synthetic_char_large_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/synthetic_char_large_3gram/eval_out/eval.log&


synthetic_char_interp_3gram: /mnt/tannon/lms/synthetic_data/orig/char_level/orig_chargen_int.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&


evaluate_synthetic_char_interp_3gram:
	mkdir -p $(OUT_DIR)/synthetic_char_interp_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/synthetic_char_interp_3gram/lw_out/ \
	$(OUT_DIR)/synthetic_char_interp_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/synthetic_char_interp_3gram/eval_out/eval.log&


synthetic_word_small_3gram: /mnt/tannon/lms/synthetic_data/orig/word_level/mkn3_200000.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&


evaluate_synthetic_word_small_3gram:
	mkdir -p $(OUT_DIR)/synthetic_word_small_3gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/synthetic_word_small_3gram/lw_out/ \
	$(OUT_DIR)/synthetic_word_small_3gram/eval_out/ \
	11 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/synthetic_word_small_3gram/eval_out/eval.log&


#######################################

ood_90000_mkn3: /mnt/tannon/lms/oov_data/orig/lms/90000_mkn3.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/$@/lw_out/lw.log&

evaluate_ood_90000_mkn3:
	mkdir -p $(OUT_DIR)/ood_90000_mkn3/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/ood_90000_mkn3/lw_out/ \
	$(OUT_DIR)/ood_90000_mkn3/eval_out/ \
	11 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/ood_90000_mkn3/eval_out/eval.log&


#######################################

ood_open_80000_mkn3: /mnt/tannon/lms/oov_data/orig/lms/80000_open_mkn3.arpa
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
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
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
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/ood_open_80000_mkn3/eval_out/eval.log&


#######################################
## Experiment systems
#######################################

compile_with_interpolated_large_3gram: /mnt/tannon/lms/added_gsw_data/int_lrg_3gram.arpa
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/int_lrg_3gram/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/int_lrg_3gram/lw_out/lw.log&


evaluate_with_interpolated_large_3gram:
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/int_lrg_3gram/lw_out/ \
	$(OUT_DIR)/int_lrg_3gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/int_lrg_3gram/eval_out/eval.log&


##############################
## 2-gram LM
###############################

compile_with_2gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_2.arpa
	mkdir -p $(OUT_DIR)/2gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/2gram/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
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
	14 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $</eval_out/eval.log&


##############################
## 3-gram LM
###############################

compile_with_3gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_3.arpa
	mkdir -p $(OUT_DIR)/3gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/3gram/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
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
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $</eval_out/eval.log&


##########################
## 4-gram LM
##########################

compile_with_4gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa
	mkdir -p $(OUT_DIR)/4gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/4gram/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
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
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $</eval_out/eval.log&

###############################
## 5-gram LM
###############################

compile_with_5gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_5.arpa
	mkdir -p $(OUT_DIR)/5gram/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/5gram/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
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
	13 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $</eval_out/eval.log&

###########################
## 2gram LRG
###########################

compile_with_2gram_lrg: /mnt/tannon/lms/orig_lrg_2gram.arpa
	mkdir -p $(OUT_DIR)/2gram_lrg/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/2gram_lrg/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/2gram_lrg/lw_out/lw.log&

evaluate_with_2gram_lrg: $(OUT_DIR)/2gram_lrg
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$</lw_out/ \
	$</eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $</eval_out/eval.log&

	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt > $</rnnlm/orig_utt.txt

train_rnnlm_for_2gram_large: $(OUT_DIR)/2gram_lrg
	mkdir -p $</rnnlm/text
	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt > $</rnnlm/orig_utt.txt
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/run_lstm_tdnn_1b_wsj.sh \
	$</rnnlm/orig_utt.txt \
	$(OUT_DIR)/am_out/initial_data/ling/lexiconp.txt \
	$</rnnlm/text \
	$</rnnlm/model \
	> $</rnnlm/rnnlm.log&

# train_rnnlm_for_2gram_large: $(OUT_DIR)/2gram_lrg
# 	mkdir -p $</rnnlm/text
# 	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt $</rnnlm/text/train.txt
# 	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt $</rnnlm/text/dev.txt
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	rnnlm/run_lstm_tdnn_1b_wsj.sh \
# 	$</rnnlm/text/train.txt \
# 	$(OUT_DIR)/am_out/initial_data/ling/lexiconp.txt \
# 	$</rnnlm/text \
# 	$</rnnlm/model \
# 	> $</rnnlm/rnnlm.log&

rescore_2gram_lrg_with_rnnlm: $(OUT_DIR)/2gram_lrg
	mkdir -p $</rescore_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</lw_out/tmp/lang/ \
    $</rnnlm/model/ \
    $</eval_out/lang/ \
    $</eval_out/decode/ \
    $</rescore_out \
	12 \
	12 \
	/mnt/tannon/corpus_data/norm2dieth.json \
    > $</rescore_out/rescore.log&

# ##########################
# ## 4 gram lm unk
# #########################

# compile_with_4gram_unk: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa
# 	mkdir -p $(OUT_DIR)/4gram_unk/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/4gram_unk/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/4gram_unk/lw_out/lw.log&


# evaluate_with_4gram_unk: $(OUT_DIR)/4gram_unk
# 	mkdir -p $</eval_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$</lw_out/ \
# 	$</eval_out/ \
# 	12 \
# 	orig \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $</eval_out/eval.log&

##############################################

compile_with_3gram_open: /mnt/tannon/lms_april2020/mitlm_3gram_open.arpa
	mkdir -p $(OUT_DIR)/3gram_open/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/3gram_open/lw_out/ \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/3gram_open/lw_out/lw.log&


evaluate_with_3gram_open: $(OUT_DIR)/3gram_open
	mkdir -p $</eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$</lw_out/ \
	$</eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $</eval_out/eval.log&