##############
## baseline
##############

## data preparation
dev := /home/tannon/code_base
out_dir := /home/tannon/kaldi_wrk_dir/baseline/original

## create training set from Fran's original data
baseline_xml_to_csv:
	python ${dev}/archimob/process_exmaralda_xml.py \
	-i /home/ubuntu/data/original/all_xml/*.xml \
	-format xml \
	-o /home/tannon/processed/baseline.csv

## filter out utterances that appear in the final test set
split_baseline_data:
	python3 ${dev}/archimob/split_data.py \
	-i /home/tannon/processed/baseline.csv \
	-o /home/tannon/processed/baseline \
	-t /home/ubuntu/data/archimob_r2/meta_info/test_set.json
	# remove the test set extracted in this process since it's not useful for us
	rm /home/tannon/processed/baseline/test.csv
	rm /home/tannon/processed/baseline.csv

########################
## train acoustic models
########################

train_baseline:
	cd ${dev} && echo "working from ${dev}" && nohup \
	./train_AM.sh \
	--num_jobs 80 \
	/home/tannon/processed/baseline/train.csv \
	/home/ubuntu/data/archimob_r2/audio \
	${out_dir}/am_out \
	> ${out_dir}/nohup.log &

train_original_baseline_lm:
	bash ./archimob/simple_lm.sh \
	-o 3 \
	-c manual/clusters.txt \
	-t original \
	/home/tannon/processed/baseline/train.csv \
	/home/tannon/lm/baseline/original

# train_norm_baseline_lm:
# 	bash ./archimob/simple_lm.sh \
# 	-o 3 \
# 	-c manual/clusters.txt \
# 	-t normalized \
# 	/home/tannon/processed/baseline/train.csv \
# 	/home/tannon/lm/baseline/norm
