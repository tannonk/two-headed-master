##############
## baseline archimob_r1
##############

DEV := /home/tannon/kaldi_wrk/two-headed-master
OUT_DIR := /mnt/tannon/processed/archimob_r1/orig
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

# train_am:
# 	mkdir -p $(OUT_DIR)/am_out
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	./train_AM.sh \
# 	--num_jobs 40 \
# 	$(TRAIN_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out \
# 	> $(OUT_DIR)/am_out/am.log &

#######################################
## build HCLG.fst and decode on dev set
#######################################

compile_baseline_system:
	mkdir -p $(OUT_DIR)/baseline/lw_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	/mnt/tannon/lms/archimob1_orig_3gram.arpa \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/baseline/lw_out \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
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
	$(OUT_DIR)/baseline/lw_out \
	$(OUT_DIR)/baseline/eval_out \
	12 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/baseline/eval_out/eval.log &

#######################
## Experiments
#######################

compile_system_with_limited_vocab_lm: /mnt/tannon/lms/archimob1_orig_3gram_limited_vocab.arpa
	mkdir -p $(OUT_DIR)/limited_vocab_lm/lw_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/limited_vocab_lm/lw_out \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/limited_vocab_lm/lw_out/lw.log &

evaluate_system_with_limited_vocab_lm:
	mkdir -p $(OUT_DIR)/limited_vocab_lm/eval_out/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./evaluate.sh \
	$(TEST_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/am_out \
	$(OUT_DIR)/limited_vocab_lm/lw_out \
	$(OUT_DIR)/limited_vocab_lm/eval_out \
	14 \
	orig \
	/mnt/tannon/corpus_data/norm2dieth_clean.json \
	> $(OUT_DIR)/limited_vocab_lm/eval_out/eval.log &

############################

compile_system_with_archimob2_lm: /mnt/tannon/lms/archimob2_orig_3gram.arpa
	mkdir -p $(OUT_DIR)/archimob2_lm/lw_out
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	bash ./compile_and_decode.sh \
	$< \
	$(OUT_DIR)/am_out \
	$(DEV_CSV) \
	$(AUDIO) \
	$(OUT_DIR)/archimob2_lm/lw_out \
	orig \
	"--min-lmwt 1 --max-lmwt 20" \
	/mnt/tannon/corpus_data/norm2dieth.json \
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
	orig \
	/mnt/tannon/corpus_data/norm2dieth.json \
	> $(OUT_DIR)/archimob2_lm/eval_out/eval.log &


# train_lm:
# 	mkdir -p $(OUT_DIR)/logs
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	bash ./archimob/simple_lm.sh \
# 	-o 3 \
# 	-c manual/clusters.txt \
# 	-t orig \
# 	$(TRAIN_CSV) \
# 	$(OUT_DIR)/lms/archimob_r1/ \
# 	> $(OUT_DIR)/logs/lm.log &
#
# compile_lingware_1:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./compile_lingware.sh \
# 	$(OUT_DIR)/am_out/initial_data/ling/ \
# 	$(OUT_DIR)/am_out/initial_data/tmp/vocabulary.txt \
# 	$(OUT_DIR)/lms/archimob_r1/language_model.arpa \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc/ \
# 	$(OUT_DIR)/ling1_out/ \
# 	> $(OUT_DIR)/logs/lingware1.log &
#
# decode_1:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./decode_nnet.sh \
# 	--num-jobs 93 \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc \
# 	$(OUT_DIR)/ling1_out/ \
# 	$(OUT_DIR)/decode1_out/ \
# 	> $(OUT_DIR)/logs/decode1.log &
#
# #########################
# ## system using LM trained on more training data than AM
# #########################
#
# compile_lingware_2:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./compile_lingware.sh \
# 	$(OUT_DIR)/am_out/initial_data/ling/ \
# 	$(OUT_DIR)/am_out/initial_data/tmp/vocabulary.txt \
# 	/home/tannon/processed/exp1/orig/lms/lm1_exp1_train/language_model.arpa \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc/ \
# 	$(OUT_DIR)/ling2_out/ \
# 	> $(OUT_DIR)/logs/lingware2.log &
#
# decode_2:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./decode_nnet.sh \
# 	--num-jobs 91 \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc \
# 	$(OUT_DIR)/ling2_out/ \
# 	$(OUT_DIR)/decode2_out/ \
# 	> $(OUT_DIR)/logs/decode2.log &
#
# #########################
# ## system using LM trained on more training data than AM and larger vocabulary
# ## UNSUCCESSFUL! Tried decoding with lingware from compile_lingware_2 but didn't work
# #########################
#
# # compile_lingware_3:
# # 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# # 	./compile_lingware.sh \
# # 	/home/tannon/processed/exp1/orig/am_out/initial_data/ling/ \
# # 	/home/tannon/processed/exp1/orig/am_out/initial_data/tmp/vocabulary.txt \
# # 	/home/tannon/processed/exp1/orig/lms/lm1_exp1_train/language_model.arpa \
# # 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc/ \
# # 	$(OUT_DIR)/ling3_out/ \
# # 	> $(OUT_DIR)/logs/lingware3.log &
# #
# # decode_3:
# # 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# # 	./decode_nnet.sh \
# # 	--num-jobs 91 \
# # 	$(TEST_CSV) \
# # 	$(AUDIO) \
# # 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc \
# # 	$(OUT_DIR)/ling3_out/ \
# # 	$(OUT_DIR)/decode3_out/ \
# # 	> $(OUT_DIR)/logs/decode3.log &
#
#
# ##############################
# ## plugging in archi+noah lm
# ##############################
#
# compile_lingware_4:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./compile_lingware.sh \
# 	$(OUT_DIR)/am_out/initial_data/ling/ \
# 	$(OUT_DIR)/am_out/initial_data/tmp/vocabulary.txt \
# 	/home/tannon/lms/archi_noah.arpa \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc/ \
# 	$(OUT_DIR)/ling4_out/ \
# 	> $(OUT_DIR)/logs/lingware4.log &
#
# decode_4:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./decode_nnet.sh \
# 	--num-jobs 91 \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc \
# 	$(OUT_DIR)/ling4_out/ \
# 	$(OUT_DIR)/decode4_out/ \
# 	> $(OUT_DIR)/logs/decode4.log &
#
# ##############################
# ## plugging in archi+noah+lcc2017 lm
# ##############################
#
# compile_lingware_5:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./compile_lingware.sh \
# 	$(OUT_DIR)/am_out/initial_data/ling/ \
# 	$(OUT_DIR)/am_out/initial_data/tmp/vocabulary.txt \
# 	/home/tannon/lms/archi_noah_lcc.arpa \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc/ \
# 	$(OUT_DIR)/ling5_out/ \
# 	> $(OUT_DIR)/logs/lingware5.log &
#
# decode_5:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./decode_nnet.sh \
# 	--num-jobs 91 \
# 	$(TEST_CSV) \
# 	$(AUDIO) \
# 	$(OUT_DIR)/am_out/models/discriminative/nnet_disc \
# 	$(OUT_DIR)/ling5_out/ \
# 	$(OUT_DIR)/decode5_out/ \
# 	> $(OUT_DIR)/logs/decode5.log &
#
#
# test_cer_decode:
# 	cd $(DEV) && echo "changing dir to ${dev}" && nohup \
# 	./decode_nnet.sh \
# 	--num-jobs 91 \
# 	/home/tannon/processed/trash/old_splits/test.csv \
# 	$(AUDIO) \
# 	/home/tannon/processed/baseline/orig/am_out/models/discriminative/nnet_disc \
# 	/home/tannon/processed/baseline/orig/ling1_out/ \
# 	/home/tannon/processed/baseline/orig/decode_cer_out/ \
# 	> /home/tannon/processed/baseline/orig/logs/decode_cer.log &
