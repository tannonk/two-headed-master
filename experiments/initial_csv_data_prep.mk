# Step 1) convert archimob xml files to csv
# Step 2) syncronize csv with available wav files
# Step 3) split corpus csv into train and test splits
# Step 4) remove unnecessary test file and move true test file to own directory

scripts_dir := /home/tannon/kaldi_wrk/two-headed-master/archimob
archimob_files := /mnt/data
csv_files := /mnt/tannon/corpus_data/csv_files
my_scripts := /home/tannon/my_scripts
validation_scripts := /home/tannon/kaldi_wrk/two-headed-master/archimob/validation

fix_xmls:
	python3 ${my_scripts}/add_archimob_corrections.py \
	/mnt/tannon/corpus_data/updated_corrections_larissa_11_10_2019.json \
	${archimob_files}/archimob_r1/xml \
	${archimob_files}/archimob_r1/xml_corrected/
	python3 ${my_scripts}/add_archimob_corrections.py \
	/mnt/tannon/corpus_data/updated_corrections_larissa_11_10_2019.json \
	${archimob_files}/archimob_r2/xml \
	${archimob_files}/archimob_r2/xml_corrected/

archimob_r1:
	mkdir -p ${csv_files}/archimob_r1/
	python ${scripts_dir}/process_exmaralda_xml.py \
	-i ${archimob_files}/archimob_r1/xml_corrected/*.xml \
	-f xml \
	-o ${csv_files}/archimob_r1/archimob_r1.csv
	python ${scripts_dir}/sync_csv_wav.py \
	-i ${csv_files}/archimob_r1/archimob_r1.csv \
	-chw ${archimob_files}/archimob_r2/audio
	python3 ${scripts_dir}/split_data.py \
	-i ${csv_files}/archimob_r1/archimob_r1.csv \
	-o ${csv_files}/archimob_r1/ \
	--test ${archimob_files}/archimob_r2/meta_info/testset_utterances.json
	rm ${csv_files}/archimob_r1/test.csv

archimob_r2:
	mkdir -p ${csv_files}/archimob_r2/
	python ${scripts_dir}/process_exmaralda_xml.py \
	-i ${archimob_files}/archimob_r2/xml_corrected/*.xml \
	-f xml \
	-o ${csv_files}/archimob_r2/archimob_r2.csv
	python ${scripts_dir}/sync_csv_wav.py \
	-i ${csv_files}/archimob_r2/archimob_r2.csv \
	-chw ${archimob_files}/archimob_r2/audio
	python3 ${scripts_dir}/split_data.py \
	-i ${csv_files}/archimob_r2/archimob_r2.csv \
	-o ${csv_files}/archimob_r2/ \
	--test ${archimob_files}/archimob_r2/meta_info/testset_utterances.json
	mkdir -p ${csv_files}/test_files
	mv ${csv_files}/archimob_r2/test.csv ${csv_files}/test_files/

check_audio_files:
	python3 ${validation_scripts}/validate_audio_files.py ${archimob_files}/archimob_r2/audio

compare_transcriptions:
	python3 ${validation_scripts}/validate_orig_norm.py ${csv_files}/archimob_r1/archimob_r1.csv
	python3 ${validation_scripts}/validate_orig_norm.py ${csv_files}/archimob_r1/train.csv
	python3 ${validation_scripts}/validate_orig_norm.py ${csv_files}/archimob_r2/archimob_r2.csv
	python3 ${validation_scripts}/validate_orig_norm.py ${csv_files}/archimob_r2/train.csv

inspect_csv_files:
	python3 ${validation_scripts}/validate_csv.py ${csv_files}/test_files/test.csv ${archimob_files}/archimob_r2/audio
	python3 ${validation_scripts}/validate_csv.py ${csv_files}/archimob_r1/train.csv ${archimob_files}/archimob_r2/audio
	python3 ${validation_scripts}/validate_csv.py ${csv_files}/archimob_r2/train.csv ${archimob_files}/archimob_r2/audio

validate_splits:
	python3 ${validation_scripts}/validate_splits.py ${csv_files}/archimob_r1/train.csv ${csv_files}/test_files/test.csv
	python3 ${validation_scripts}/validate_splits.py ${csv_files}/archimob_r2/train.csv ${csv_files}/test_files/test.csv

# conda activate
# source activate py37
create_normalised_to_dieth_mapping:
	python3 ${my_scripts}/collect_normalisation_dictionary.py ${archimob_files}/archimob_r2/xml_corrected/ /mnt/tannon/corpus_data/norm2dieth.json
