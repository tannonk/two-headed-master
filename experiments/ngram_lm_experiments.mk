### LM experiments

### Incremental LM NORM
# preprocess
prep_increment_norm_train_data:
	sed -i 's/ß/ss/g' /mnt/tannon/corpus_data/de_data/tuda_de.txt
	sed -i 's/ß/ss/g' /mnt/tannon/corpus_data/de_data/tatoeba_de.txt
	sed -i 's/ß/ss/g' /mnt/tannon/corpus_data/de_data/opensubtitles_de.txt
	shuf -n 1500000 /mnt/tannon/corpus_data/de_data/opensubtitles_de.txt > /mnt/tannon/corpus_data/de_data/opensubtitles_de_sample.txt

# cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt \
# /mnt/tannon/corpus_data/de_data/tueba-ds.w.txt \
# /mnt/tannon/corpus_data/de_data/tuda_speech_de.txt \
# /mnt/tannon/corpus_data/de_data/tatoeba_de.txt \
# /mnt/tannon/corpus_data/de_data/opensubtitles_de_sample.txt \
# > /mnt/tannon/lms/incremental_training_data/norm/train.txt

move_increment_norm_train_data:
	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt \
	/mnt/tannon/corpus_data/de_data/tueba-ds.w.txt \
	/mnt/tannon/corpus_data/de_data/tatoeba_de.txt \
	/mnt/tannon/corpus_data/de_data/opensubtitles_de_sample.txt \
	> /mnt/tannon/lms/incremental_training_data/norm/train.txt
	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_norm_utt.txt /mnt/tannon/lms/incremental_training_data/norm/dev.txt
	cp /mnt/tannon/corpus_data/csv_files/test_files/test_norm_utt.txt /mnt/tannon/lms/incremental_training_data/norm/test.txt

# run exp
# and
# parse log file

run_increment_norm_exp:
	nohup bash /home/tannon/kaldi_wrk/two-headed-master/lms/incremental_training_data.sh \
	/mnt/tannon/lms/incremental_training_data/norm/ \
	2010000 \
	> /mnt/tannon/lms/incremental_training_data/norm/log.txt&

# python3 /mnt/tannon/my_scripts/parse_incremental_training_lm_log.py \
# /mnt/tannon/lms/incremental_training_data/norm/log.txt \
# > /mnt/tannon/lms/incremental_training_data/norm/incremental_LM_norm.csv

### Incremental LM ORIG

# move files
prep_increment_orig_train_data:
	sed -i 's/ß/ss/g' /mnt/tannon/corpus_data/gsw_data/proc.noah.txt
	sed -i 's/ß/ss/g' /mnt/tannon/corpus_data/gsw_data/proc.ch_web_2017.txt
	cat /mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt \
	/mnt/tannon/corpus_data/gsw_data/proc.transcripts_schawinski.txt \
	/mnt/tannon/corpus_data/gsw_data/proc.noah.txt \
	/mnt/tannon/corpus_data/gsw_data/proc.transcripts_phonogrammarchiv.txt \
	/mnt/tannon/corpus_data/gsw_data/proc.ch_web_2017.txt \
	> /mnt/tannon/lms/incremental_training_data/orig/train.txt
	cp /mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt /mnt/tannon/lms/incremental_training_data/orig/dev.txt
	cp /mnt/tannon/corpus_data/csv_files/test_files/test_orig_utt.txt /mnt/tannon/lms/incremental_training_data/orig/test.txt

# run exp
# and
# parse log file
run_increment_orig_exp: /mnt/tannon/lms/incremental_training_data/orig/train.txt
	nohup bash /home/tannon/kaldi_wrk/two-headed-master/lms/incremental_training_data.sh \
	/mnt/tannon/lms/incremental_training_data/orig/ \
	200000 \
	> /mnt/tannon/lms/incremental_training_data/orig/log.txt&

# python3 /mnt/tannon/my_scripts/parse_incremental_training_lm_log.py \
# /mnt/tannon/lms/incremental_training_data/orig/log.txt \
# > /mnt/tannon/lms/incremental_training_data/orig/incremental_LM_orig.csv

# manually download parsed results csv and recreate graphs with plot_incrementing_training_data_on_ppl.ipynb

###############################################


### stat LM exp

run_norm_stat_lm_exp:
	nohup bash /home/tannon/kaldi_wrk/two-headed-master/lms/stat_lm_comparison.sh \
	/mnt/tannon/corpus_data/csv_files/archimob_r2/train_norm_utt.txt \
	/mnt/tannon/corpus_data/csv_files/archimob_r2/dev_norm_utt.txt \
	/mnt/tannon/corpus_data/csv_files/test_files/test_norm_utt.txt \
	/mnt/tannon/processed/archimob_r2/norm/am_out/initial_data/tmp/vocabulary.txt \
	/mnt/tannon/lms/stat_ngram_exp/norm \
	> /mnt/tannon/lms/stat_ngram_exp/norm/log.txt&

# python3 /home/tannon/my_scripts/parse_lm_stats.py \
# /mnt/tannon/lms/stat_ngram_exp/norm/log.txt \
# > /mnt/tannon/lms/stat_ngram_exp/norm/stat_ngram_comp_norm.csv

run_orig_stat_lm_exp:
	nohup bash /home/tannon/kaldi_wrk/two-headed-master/lms/stat_lm_comparison.sh \
	/mnt/tannon/corpus_data/csv_files/archimob_r2/train_orig_utt.txt \
	/mnt/tannon/corpus_data/csv_files/archimob_r2/dev_orig_utt.txt \
	/mnt/tannon/corpus_data/csv_files/test_files/test_orig_utt.txt \
	/mnt/tannon/processed/archimob_r2/orig/am_out/initial_data/tmp/vocabulary.txt \
	/mnt/tannon/lms/stat_ngram_exp/orig \
	> /mnt/tannon/lms/stat_ngram_exp/orig/log.txt&

# python3 /home/tannon/my_scripts/parse_lm_stats.py \
# /mnt/tannon/lms/stat_ngram_exp/orig/log.txt \
# > /mnt/tannon/lms/stat_ngram_exp/orig/stat_ngram_comp_orig.csv


# download parsed results csv and recreate graphs with stat_ngram_lm_exp.ipynb

