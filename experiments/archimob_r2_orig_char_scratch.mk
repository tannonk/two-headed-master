##############
## baseline archimob_r2
##############

DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR_1 := /mnt/tannon/processed/archimob_r2/char_scratch_1
OUT_DIR_2 := /mnt/tannon/processed/archimob_r2/char_scratch_2
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
# 	./train_character_AM.sh \
# 	--num_jobs 16 \
# 	$(TRAIN_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	> $(OUT_DIR)/am_out/am.log &

graph_9gram_1: /mnt/tannon/lms/grapheme_level_2/grapheme_lm_9gram.arpa
	mkdir -p $(OUT_DIR_1)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode_char.sh \
	$< \
	$(OUT_DIR_1)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR_1)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth_orig.json \
	$(OUT_DIR_1)/am_out/initial_data/tmp/vocabulary.txt \
	> $(OUT_DIR_1)/$@/lw_out/lw.log&

evaluate_graph_9gram_1:
	mkdir -p $(OUT_DIR_1)/graph_9gram_1/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate_char.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR_1)/am_out \
	$(OUT_DIR_1)/graph_9gram_1/lw_out/ \
	$(OUT_DIR_1)/graph_9gram_1/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR_1)/graph_9gram_1/eval_out/eval.log&


######################

graph_12gram_1: /mnt/tannon/lms/grapheme_level_2/grapheme_lm_12gram.arpa
	mkdir -p $(OUT_DIR_1)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode_char.sh \
	$< \
	$(OUT_DIR_1)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR_1)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth_orig.json \
	$(OUT_DIR_1)/am_out/initial_data/tmp/vocabulary.txt \
	> $(OUT_DIR_1)/$@/lw_out/lw.log&

evaluate_graph_12gram_1:
	mkdir -p $(OUT_DIR_1)/graph_12gram_1/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate_char.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR_1)/am_out \
	$(OUT_DIR_1)/graph_12gram_1/lw_out/ \
	$(OUT_DIR_1)/graph_12gram_1/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR_1)/graph_12gram_1/eval_out/eval.log&



#######################

## USE AM WITH ADDITIONAL PHONES:

graph2_9gram: /mnt/tannon/lms/grapheme_level_2/grapheme_lm_9gram.arpa
	mkdir -p $(OUT_DIR_2)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode_char.sh \
	$< \
	$(OUT_DIR_2)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR_2)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR_2)/$@/lw_out/lw.log&


evaluate_graph2_9gram:
	mkdir -p $(OUT_DIR_2)/graph_9gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate_char.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR_2)/am_out \
	$(OUT_DIR_2)/graph_9gram/lw_out/ \
	$(OUT_DIR_2)/graph_9gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR_2)/graph_9gram/eval_out/eval.log&

graph2_15gram: /mnt/tannon/lms/grapheme_level_2/grapheme_lm_15gram.arpa
	mkdir -p $(OUT_DIR_2)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode_char.sh \
	$< \
	$(OUT_DIR_2)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR_2)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR_2)/$@/lw_out/lw.log&


evaluate_graph2_15gram:
	mkdir -p $(OUT_DIR_2)/graph2_15gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate_char.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR_2)/am_out \
	$(OUT_DIR_2)/graph2_15gram/lw_out/ \
	$(OUT_DIR_2)/graph2_15gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR_2)/graph2_15gram/eval_out/eval.log&

graph_20gram: /mnt/tannon/lms/grapheme_level_2/grapheme_lm_20gram.arpa
	mkdir -p $(OUT_DIR_2)/$@/lw_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode_char.sh \
	$< \
	$(OUT_DIR_2)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR_2)/$@/lw_out/ \
	orig \
	"--min-lmwt 5 --max-lmwt 20" \
	> $(OUT_DIR_2)/$@/lw_out/lw.log&


evaluate_graph_20gram:
	mkdir -p $(OUT_DIR_2)/graph_20gram/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate_char.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR_2)/am_out \
	$(OUT_DIR_2)/graph_20gram/lw_out/ \
	$(OUT_DIR_2)/graph_20gram/eval_out/ \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR_2)/graph_20gram/eval_out/eval.log&


# baseline: /mnt/tannon/lms/grapheme_level/with_spaces/graph_5gram.arpa
# 	mkdir -p $(OUT_DIR)/$@/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode_char.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/$@/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	> $(OUT_DIR)/$@/lw_out/lw.log&


# baseline: /mnt/tannon/lms/grapheme_level/with_spaces/graph_5gram.arpa
# 	mkdir -p $(OUT_DIR)/$@/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/$@/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/$@/lw_out/lw.log&



# ####################################
# ## decode on test set for evaluation
# ####################################

# evaluate:
# 	mkdir -p $(OUT_DIR)/baseline/eval_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$(OUT_DIR)/baseline/lw_out/ \
# 	$(OUT_DIR)/baseline/eval_out/ \
# 	12 \
# 	orig \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/baseline/eval_out/eval.log&


# #######################################
# ## Experiment systems
# #######################################

# compile_with_interpolated_large_3gram: /mnt/tannon/lms/added_gsw_data/int_lrg_3gram.arpa
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/int_lrg_3gram/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/int_lrg_3gram/lw_out/lw.log&


# evaluate_with_interpolated_large_3gram:
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$(OUT_DIR)/int_lrg_3gram/lw_out/ \
# 	$(OUT_DIR)/int_lrg_3gram/eval_out/ \
# 	12 \
# 	orig \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/int_lrg_3gram/eval_out/eval.log&


# ##############################
# ## 2-gram LM
# ###############################

# compile_with_2gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_2.arpa
# 	mkdir -p $(OUT_DIR)/2gram/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/2gram/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/2gram/lw_out/lw.log&

# evaluate_with_2gram: $(OUT_DIR)/2gram
# 	mkdir -p $</eval_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$</lw_out/ \
# 	$</eval_out/ \
# 	14 \
# 	orig \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $</eval_out/eval.log&


# ##############################
# ## 3-gram LM
# ###############################

# compile_with_3gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_3.arpa
# 	mkdir -p $(OUT_DIR)/3gram/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/3gram/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/3gram/lw_out/lw.log&

# evaluate_with_3gram: $(OUT_DIR)/3gram
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


# ##########################
# ## 4-gram LM
# ##########################

# compile_with_4gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa
# 	mkdir -p $(OUT_DIR)/4gram/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/4gram/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/4gram/lw_out/lw.log&


# evaluate_with_4gram: $(OUT_DIR)/4gram
# 	mkdir -p $</eval_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$</lw_out/ \
# 	$</eval_out/ \
# 	13 \
# 	orig \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $</eval_out/eval.log&

# ###############################
# ## 5-gram LM
# ###############################

# compile_with_5gram: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_5.arpa
# 	mkdir -p $(OUT_DIR)/5gram/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/5gram/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/5gram/lw_out/lw.log&

# evaluate_with_5gram: $(OUT_DIR)/5gram
# 	mkdir -p $</eval_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./evaluate.sh \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	$</lw_out/ \
# 	$</eval_out/ \
# 	13 \
# 	orig \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $</eval_out/eval.log&

# ###########################
# ## 2gram LRG
# ###########################

# compile_with_2gram_lrg: /mnt/tannon/lms/orig_lrg_2gram.arpa
# 	mkdir -p $(OUT_DIR)/2gram_lrg/lw_out/
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	bash ./compile_and_decode.sh \
# 	$< \
# 	$(OUT_DIR)/am_out \
# 	$(DEV_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/2gram_lrg/lw_out/ \
# 	orig \
# 	"--min-lmwt 1 --max-lmwt 20" \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
# 	> $(OUT_DIR)/2gram_lrg/lw_out/lw.log&

# evaluate_with_2gram_lrg: $(OUT_DIR)/2gram_lrg
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

# 	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt > $</rnnlm/orig_utt.txt

# train_rnnlm_for_2gram_large: $(OUT_DIR)/2gram_lrg
# 	mkdir -p $</rnnlm/text
# 	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt > $</rnnlm/orig_utt.txt
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	rnnlm/run_lstm_tdnn_1b_wsj.sh \
# 	$</rnnlm/orig_utt.txt \
# 	$(OUT_DIR)/am_out/initial_data/ling/lexiconp.txt \
# 	$</rnnlm/text \
# 	$</rnnlm/model \
# 	> $</rnnlm/rnnlm.log&

# # train_rnnlm_for_2gram_large: $(OUT_DIR)/2gram_lrg
# # 	mkdir -p $</rnnlm/text
# # 	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt $</rnnlm/text/train.txt
# # 	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt $</rnnlm/text/dev.txt
# # 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# # 	rnnlm/run_lstm_tdnn_1b_wsj.sh \
# # 	$</rnnlm/text/train.txt \
# # 	$(OUT_DIR)/am_out/initial_data/ling/lexiconp.txt \
# # 	$</rnnlm/text \
# # 	$</rnnlm/model \
# # 	> $</rnnlm/rnnlm.log&

# rescore_2gram_lrg_with_rnnlm: $(OUT_DIR)/2gram_lrg
# 	mkdir -p $</rescore_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	rnnlm/lmrescore.sh \
#     $</lw_out/tmp/lang/ \
#     $</rnnlm/model/ \
#     $</eval_out/lang/ \
#     $</eval_out/decode/ \
#     $</rescore_out \
# 	12 \
# 	12 \
# 	/mnt/tannon/corpus_data/norm2dieth.json \
#     > $</rescore_out/rescore.log&

# # ##########################
# # ## 4 gram lm unk
# # #########################

# # compile_with_4gram_unk: /mnt/tannon/lms/stat_ngram_exp/orig/mitlm/mitlm_mkn_open_tuned_4.arpa
# # 	mkdir -p $(OUT_DIR)/4gram_unk/lw_out/
# # 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# # 	bash ./compile_and_decode.sh \
# # 	$< \
# # 	$(OUT_DIR)/am_out \
# # 	$(DEV_CSV) \
# # 	$(AUDIO) \
# # 	$(OUT_DIR)/4gram_unk/lw_out/ \
# # 	orig \
# # 	"--min-lmwt 1 --max-lmwt 20" \
# # 	/mnt/tannon/corpus_data/norm2dieth.json \
# # 	> $(OUT_DIR)/4gram_unk/lw_out/lw.log&


# # evaluate_with_4gram_unk: $(OUT_DIR)/4gram_unk
# # 	mkdir -p $</eval_out/
# # 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# # 	bash ./evaluate.sh \
# # 	$(TEST_CSV) \
# # 	$(AUDIO) \
# # 	$(OUT_DIR)/am_out \
# # 	$</lw_out/ \
# # 	$</eval_out/ \
# # 	12 \
# # 	orig \
# # 	/mnt/tannon/corpus_data/norm2dieth.json \
# # 	> $</eval_out/eval.log&
