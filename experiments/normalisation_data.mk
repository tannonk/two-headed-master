# conda activate
# source activate py37

create_normalised_to_dieth_mapping:
	python3 ${my_scripts}/collect_normalisation_dictionary.py ${archimob_files}/archimob_r2/xml_corrected/ /mnt/tannon/corpus_data/norm2dieth.json
