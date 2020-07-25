# generate pie charts for error analysis

script_loc := '/home/tannon/my_scripts/error_analysis.py'
out_dir := '/mnt/tannon/error_analysis/'
sys_dir := '/mnt/tannon/processed/archimob_r2/'

# orig:

original_systems:
	python3 $(script_loc) $(sys_dir)/orig/baseline/ $(out_dir)/orig.mkn3.errors.png
	python3 $(script_loc) $(sys_dir)/orig/mitlm_mkn_5gram/ $(out_dir)/orig.mkn5.errors.png
	python3 $(script_loc) $(sys_dir)/orig/mitlm_mkn_5gram/ $(out_dir)/orig.mkn5.errors.png
	python3 $(script_loc) $(sys_dir)/orig/orig_lrg_3gram $(out_dir)/orig.mkn3_large.errors.png
	python3 $(script_loc) $(sys_dir)/orig/orig_int_lrg_3gram $(out_dir)/orig.mkn3_large_int.errors.png
	python3 $(script_loc) $(sys_dir)/orig/mitlm_mkn_open_tuned_4gram $(out_dir)/orig.mkn4_open_tuned.errors.png
	python3 $(script_loc) $(sys_dir)/orig/orig_rnnlmgen_3gram/ $(out_dir)/orig.rnnlmgen_int.errors.png

# sampa

sampa_systems:
	python3 $(script_loc) $(sys_dir)/sampa/baseline/ $(out_dir)/sampa.mkn3.errors.png
	python3 $(script_loc) $(sys_dir)/sampa/mitlm_mkn_5gram $(out_dir)/sampa.mkn5.errors.png
	python3 $(script_loc) $(sys_dir)/sampa/norm_int_lrg_3gram $(out_dir)/sampa.mkn3_large_int.errors.png
	python3 $(script_loc) $(sys_dir)/sampa/norm_lrg_3gram $(out_dir)/sampa.mkn3_large.errors.png
	python3 $(script_loc) $(sys_dir)/sampa/mitlm_mkn_open_tuned_5gram $(out_dir)/sampa.mkn5_open_tuned.errors.png
