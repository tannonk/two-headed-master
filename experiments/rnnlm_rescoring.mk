DEV := /home/tannon/kaldi_wrk/two-headed-master

build_rnnlm_a1_orig: /mnt/tannon/processed/archimob_r1/orig
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/run_tdnn_a.sh \
	/mnt/tannon/corpus_data/csv_files/archimob_r1/train_orig_utt.txt \
	$</am_out/initial_data/ling/lexiconp.txt \
	$</rnnlm_rescore/text \
	$</rnnlm_rescore/model \
	> $</rnnlm_rescore/train_rrnlm.log&

rnnlm_rescore_a1_orig: /mnt/tannon/processed/archimob_r1/orig
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</baseline/lw_out/tmp/lang/ \
    $</rnnlm_rescore/model/ \
    $</baseline/eval_out/lang/ \
    $</baseline/eval_out/decode/ \
    $</rnnlm_rescore/rescore_out/ \
    /mnt/tannon/corpus_data/norm2dieth.json \
    >> $</rnnlm_rescore/rescore.log&

# rnnlm_rescore_pruned_a1_orig: /mnt/tannon/processed/archimob_r1/orig
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	rnnlm/lmrescore_pruned.sh \
#     $</baseline/lw_out/tmp/lang/ \
#     $</rnnlm_rescore/model/ \
#     $</baseline/eval_out/lang/ \
#     $</baseline/eval_out/decode/ \
#     $</rnnlm_rescore/rescore_pruned_out/ \
#     /mnt/tannon/corpus_data/norm2dieth.json \
#     > $</rnnlm_rescore/rescore_pruned.log&

build_rnnlm_a1_norm: /mnt/tannon/processed/archimob_r1/norm
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/run_tdnn_a.sh \
	/mnt/tannon/corpus_data/csv_files/archimob_r1/train_norm_utt.txt \
	$</am_out/initial_data/ling/lexiconp.txt \
	$</rnnlm_rescore/text \
	$</rnnlm_rescore/model \
	> $</rnnlm_rescore/train_rrnlm.log&
	
rnnlm_rescore_a1_norm: /mnt/tannon/processed/archimob_r1/norm
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</lw_out/tmp/lang/ \
    $</rnnlm_rescore/model/ \
    $</eval_out/lang/ \
    $</eval_out/decode \
    $</rnnlm_rescore/rescore_out \
    >> $</rnnlm_rescore/rescore.log&

# build_rnnlm_a2_norm: /mnt/tannon/processed/archimob_r1/norm
# 	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
# 	rnnlm/run_tdnn_a.sh \
# 	/mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt \
# 	$</am_out/initial_data/ling/lexiconp.txt \
# 	$</rnnlm_rescore_r2/text \
# 	$</rnnlm_rescore_r2/model \
# 	> $</rnnlm_rescore_r2/train_rrnlm.log&


build_lstm_tdnn_a2_orig_800: /mnt/tannon/processed/archimob_r2/orig
	mkdir -p $</lstm_tdnn_800/
	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt > $</lstm_tdnn_800/train_dev_utt.txt
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/run_lstm_tdnn_1b_wsj.sh \
	$</lstm_tdnn_800/train_dev_utt.txt \
	$</am_out/initial_data/ling/lexiconp.txt \
	$</lstm_tdnn_800/text \
	$</lstm_tdnn_800/model \
	> $</lstm_tdnn_800/train_lstm_tdnn.log&

rnnlm_rescore_lstm_tdnn_a2_orig_800: /mnt/tannon/processed/archimob_r2/orig/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</baseline/lw_out/tmp/lang/ \
    $</lstm_tdnn_800/model/ \
    $</baseline/eval_out/lang/ \
    $</baseline/eval_out/decode \
    $</lstm_tdnn_800/rescore_out \
    >> $</lstm_tdnn_800/rescore.log&

############################

build_lstm_tdnn_a2_orig_128: /mnt/tannon/processed/archimob_r2/orig
	mkdir -p $</lstm_tdnn_128_3/text
	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt $</lstm_tdnn_128_3/text/train.txt
	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt $</lstm_tdnn_128_3/text/dev.txt
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/run_lstm_tdnn_1b_wsj.sh \
	$</lstm_tdnn_128_3/text/train.txt \
	$</am_out/initial_data/ling/lexiconp.txt \
	$</lstm_tdnn_128_3/text \
	$</lstm_tdnn_128_3/model \
	> $</lstm_tdnn_128_3/train_lstm_tdnn.log&

rnnlm_rescore_lstm_tdnn_a2_orig_128: /mnt/tannon/processed/archimob_r2/orig/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</baseline/lw_out/tmp/lang/ \
    $</lstm_tdnn_128_3/model/ \
    $</baseline/eval_out/lang/ \
    $</baseline/eval_out/decode \
    $</lstm_tdnn_128_3/rescore_out \
	7 \
	17 \
	/mnt/tannon/corpus_data/norm2dieth.json \
    > $</lstm_tdnn_128_3/rescore.log&

#############################################

rescore_2gram_with_lstm_tdnn_a2_orig_128: /mnt/tannon/processed/archimob_r2/orig/
	mkdir -p $</2gram_rescored
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</2gram/lw_out/tmp/lang/ \
    $</lstm_tdnn_128_2/model/ \
    $</2gram/eval_out/lang/ \
    $</2gram/eval_out/decode \
    $</2gram_rescored/rescore_out \
	7 \
	17 \
	/mnt/tannon/corpus_data/norm2dieth.json \
    > $</2gram_rescored/rescore.log&

############################

# cat
# /mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt
# /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_norm_utt.txt
# > $</lstm_tdnn_rescore/train_dev_utt.txt

build_lstm_tdnn_a2_sampa: /mnt/tannon/processed/archimob_r2/sampa
	mkdir -p $</lstm_tdnn_rescore/
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/run_lstm_tdnn_1b_wsj.sh \
	$</lstm_tdnn_rescore/train_dev_utt.txt \
	$</am_out/initial_data/ling/lexiconp.txt \
	$</lstm_tdnn_rescore/text \
	$</lstm_tdnn_rescore/model \
	> $</lstm_tdnn_rescore/train_lstm_tdnn.log&

rnnlm_rescore_lstm_tdnn_a2_sampa: /mnt/tannon/processed/archimob_r2/sampa
	cd $(DEV) && echo "changing dir to ${DEV}" && nohup \
	rnnlm/lmrescore.sh \
    $</baseline/lw_out/tmp/lang/ \
    $</lstm_tdnn_rescore/model/ \
    $</baseline/eval_out/lang/ \
    $</baseline/eval_out/decode \
    $</lstm_tdnn_rescore/rescore_out \
    > $</lstm_tdnn_rescore/rescore.log&
