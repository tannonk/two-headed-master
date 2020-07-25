# generate pie charts for error analysis

# script_loc := '/home/tannon/my_scripts/error_analysis_2.py'
# out_dir := '/mnt/tannon/error_analysis/'
# sys_dir := '/mnt/tannon/processed/archimob_r2/'

conda:
	conda activate
	source activate py37

orig:
#mkn3
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/baseline/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/baseline/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/baseline/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-3.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
#mkn5
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/mitlm_mkn_5gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/mitlm_mkn_5gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/mitlm_mkn_5gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-5.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
#mitlm_mkn_open_tuned_4gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/mitlm_mkn_open_tuned_4gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/mitlm_mkn_open_tuned_4gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/mitlm_mkn_open_tuned_4gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-4_open_tuned.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
#orig_int_lrg_3gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/orig_int_lrg_3gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/orig_int_lrg_3gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/orig_int_lrg_3gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-3_interp.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
#orig_lrg_3gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/orig_lrg_3gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/orig_lrg_3gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/orig_lrg_3gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-3_large.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
#mKN-3_small
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/orig_small_3gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/orig_small_3gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/orig_small_3gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-3_small.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
#mKN-3_interp:orig+rnnlmgenerated
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/orig/orig_rnnlmgen_3gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/orig/orig_rnnlmgen_3gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/orig_rnnlmgen_3gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/orig.mKN-3_interp_rnnlmgenerated.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json


sampa:
#mkn3
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/sampa/baseline/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/sampa/baseline/eval_out/decode/scoring_kaldi/penalty_1.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/sampa/baseline/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/sampa.mKN-3.errors.png
#mitlm_mkn_5gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/sampa/mitlm_mkn_5gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/sampa/mitlm_mkn_5gram/eval_out/decode/scoring_kaldi/penalty_1.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/sampa/mitlm_mkn_5gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/sampa.mKN-5.errors.png
#norm_lrg_3gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/sampa/norm_lrg_3gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/sampa/norm_lrg_3gram/eval_out/decode/scoring_kaldi/penalty_1.0/?.txt \
	-l /mnt/tannon/processed/archimob_r2/sampa/norm_lrg_3gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/sampa.mKN-4_large.errors.png
#norm_int_lrg_3gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/sampa/norm_int_lrg_3gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/sampa/norm_int_lrg_3gram/eval_out/decode/scoring_kaldi/penalty_1.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/sampa/norm_int_lrg_3gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/sampa.mKN-3_interp.errors.png
#mitlm_mkn_open_tuned_5gram
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/sampa/mitlm_mkn_open_tuned_5gram/eval_out/decode/scoring_kaldi/test_filt.txt \
	-hyp /mnt/tannon/processed/archimob_r2/sampa/mitlm_mkn_open_tuned_5gram/eval_out/decode/scoring_kaldi/penalty_1.0/??.txt \
	-l /mnt/tannon/processed/archimob_r2/sampa/mitlm_mkn_open_tuned_5gram/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/sampa.mKN-5_open_tuned.errors.png


char_systems_1:
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/char_scratch_1/graph_9gram_1/eval_out/decode/scoring_kaldi/test_filt.words.txt \
	-hyp /mnt/tannon/processed/archimob_r2/char_scratch_1/graph_9gram_1/eval_out/decode/scoring_kaldi/penalty_0.0/??.words.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/baseline/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/char.v1.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json

char_systems_2:
	python3 /home/tannon/my_scripts/error_analysis_2.py \
	-ref /mnt/tannon/processed/archimob_r2/char_scratch_2/graph_9gram/eval_out/decode/scoring_kaldi/test_filt.words.txt \
	-hyp /mnt/tannon/processed/archimob_r2/char_scratch_2/graph_9gram/eval_out/decode/scoring_kaldi/penalty_0.0/??.words.txt \
	-l /mnt/tannon/processed/archimob_r2/orig/baseline/lw_out/tmp/lexicon/lexicon.txt \
	-p /mnt/tannon/error_analysis/char.v2.mkn-9.errors.png \
	-m /mnt/tannon/corpus_data/norm2dieth_clean.json
