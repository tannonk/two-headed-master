#!/usr/bin/python

"""
Script that takes as input a list of Exmaralda transcription files and the
corresponding wavefiles, and processes them to make them more suitable for
acoustic model training.
input:
"""

import sys
import os

import xml.etree.ElementTree as ET

import argparse
import wave

from archimob_chunk import ArchiMobChunk
from extract_wav_segment import extract_segment


def get_args():
    """
    Reads the command line options
    """

    my_desc = 'Scripts that prepares a set of Exmaralda files, and their ' \
              'waves, for acoustic model training'

    parser = argparse.ArgumentParser(description=my_desc)

    parser.add_argument('--input-exb', '-i', help='Input Exmaralda files',
                        nargs='+', required=True)

    parser.add_argument('--wav-dir', '-w', help='Folder with the wavefiles ' \
                        'corresponding to the input Exmaralda files. If not ' \
                        'given, only the transcriptions are processed',
                        default='')

    parser.add_argument('--output-file', '-o', help='Name of the output csv ' \
                        'file', required=True)

    parser.add_argument('--output-wav-dir', '-O', help='Output folder for the' \
                        ' chunked wavefiles. If not given, the wavefiles are' \
                        'just ignored', default='')

    args = parser.parse_args()

    if bool(args.wav_dir) != bool(args.output_wav_dir):
        sys.stderr.write('Error: the parameters -w and -O come together. ' \
                         'Either both of them are provided, or both of them ' \
                         'are ignored\n')
        sys.exit(1)

    return args


def get_timepoints(root):
    """
    Parses the header of the exb file to get the mapping among timepoint
    identifiers and the time they refer to (for example: TLI_0 => 0.00).
    input:
        * root (ElementTree): root of the xml tree.
    returns:
        * a dictionary mapping the timepoint identifiers in the annotations and
          the actual time they refer to.
    """

    output_dict = {}

    for time_p in root.iter('tli'):
        output_dict[time_p.get('id')] = float(time_p.get('time'))

    return output_dict


def chunk_transcriptions(root, time_dict, chunk_basename):
    """
    Extracts from the exb file the events from each tier, and creates chunks
    out of them.
    input:
        * root (ElementTree): root of the xml file.
        * time_dict (dict): dictionary with the timepoints.
        * chunk_basename (str): beginning of the chunk names
    returns:
        * a tuple with the list of chunks and the dictionary with the chunks
          that begin in each timepoint (used for overlapping)
    """

    verbose = False

    chunk_list = []
    overlap_dict = {}

    chunk_index = 1

    for tier in root.iter('tier'):

        current_spk = '{0}_{1}'.format(chunk_basename,
                                       tier.attrib.get('speaker'))

        if verbose:
            print 'New tier:'
            print '\tid = {0}'.format(tier.attrib.get('id'))
            print '\tspeaker = {0}'.format(current_spk)

        for event in tier.iter('event'):

            # Extract the info from the exb file:
            event_start = event.attrib.get('start')
            event_end = event.attrib.get('end')
            if event.text is None:
                text = ''
            else:
                text = event.text.strip()

            # Create the chunk object:
            chunk_key = ArchiMobChunk.create_chunk_key(chunk_basename,
                                                       current_spk,
                                                       chunk_index)

            # Update the chunk index
            chunk_index += 1

            if time_dict[event_end] <= time_dict[event_start]:
                sys.stderr.write('WARN: not positive duration for chunk {0} ' \
                                 '({1}, {2} - {3}. {4}). There is probably an' \
                                 ' error in the Exmaralda ' \
                                 'file\n'.format(chunk_key,
                                                 time_dict[event_start],
                                                 time_dict[event_end],
                                                 event_start, event_end))
                continue

            new_chunk = ArchiMobChunk(chunk_key, text, time_dict[event_start],
                                      time_dict[event_end], event_start,
                                      current_spk)

            if verbose:
                print '\tNew event: {0}'.format(new_chunk)

            # Add the chunk to the output list:
            chunk_list.append(new_chunk)

            # Update the overlap dictionary:
            if event_start in overlap_dict:
                overlap_dict[event_start].append(chunk_key)
            else:
                overlap_dict[event_start] = [chunk_key]


    return (chunk_list, overlap_dict)


def write_chunk_transcriptions(chunk_list, overlap_dict, output_f):
    """
    Writes the transcriptions of all the chunks to the output file.
    input:
        * chunk_list (list): list of chunks.
        * overlap_dict (dict): dictionary with the mapping from initial
          timepoints to chunks. When a timepoint corresponds to more than one
          chunk, overlapping is assumed.
        * output_f (file object): file object to write the transcriptions to.
    """

    for chunk in chunk_list:

        # Write the key and the transcription:
        output_f.write('{0},"{1}",'.format(chunk.key,
                                           chunk.trans.encode('utf8')))

        # Write the speaker id:
        output_f.write('{0},'.format(chunk.spk_id))

        # Duration:
        duration = chunk.end - chunk.beg

        output_f.write('{0:.2f},'.format(duration))

        if (len(overlap_dict[chunk.init_timepoint]) > 1 or
            '[speech_in_speech]' in chunk.trans):
            overlap = 1
        else:
            overlap = 0

        if (len(chunk.trans) == 0 or
            '[no_relevant_speech]' in chunk.trans):
            no_relevant_speech = 1
        else:
            no_relevant_speech = 0

        output_f.write('{0},{1}'.format(overlap, no_relevant_speech))

        output_f.write('\n')


def extract_wave_chunks(chunk_list, wave_in, output_dir):
    """
    Extracts the chunks from the main recording based on the timepoints of
    the chunks list
    input:
        * chunk_list (list): list with the chunks of the transcriptions
        * wave_in (Wave): wave object, with the complete recordings
          corresponding to the transcriptions.
        * output_dir (str): folder to write the chunked segments to.
    """

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for chunk in chunk_list:

        output_name = '{0}.wav'.format(os.path.join(output_dir, chunk.key))

        extract_segment(wave_in, chunk.beg, chunk.end,
                        output_name)


def main():
    """
    Main function of the program
    """

    # Get the command line options:
    args = get_args()

    # Create the output file:
    try:
        output_f = open(args.output_file, 'w')
    except IOError as err:
        sys.stderr.write('Error opening {0} ({1})\n'.format(args.output_file,
                                                            err))
        sys.exit(1)

    # Write the header:
    output_f.write('utt_id,transcription,speaker_id,duration,' \
                   'speech-in-speech,no-relevant-speech\n')

    # Create the output folder:
    if args.output_wav_dir and not os.path.exists(args.output_wav_dir):
        os.makedirs(args.output_wav_dir)

    # Process all the Exmaralda files:
    for input_file in args.input_exb:

        print 'Processing {0}'.format(input_file)

        if not os.path.exists(input_file):
            sys.stderr.write('The input Exmaralda file {0} does ' \
                             'not exist\n'.format(input_file))
            sys.exit(1)

        basename = os.path.splitext(os.path.split(input_file)[1])[0]

        # Read the xml tree:
        exb_tree = ET.parse(input_file)

        root = exb_tree.getroot()

        # Read the timepoints:
        time_dict = get_timepoints(root)

        (chunk_list, overlap_dict) = chunk_transcriptions(root, time_dict,
                                                          basename)

        write_chunk_transcriptions(chunk_list, overlap_dict, output_f)

        # Finally, extract the waveforms corresponding to the chunks:
        if args.wav_dir:
            input_wav = os.path.join(args.wav_dir, '{0}.wav'.format(basename))

            if not os.path.exists(input_wav):
                sys.stderr.write('The wavefile {0}, corresponding to {1}, ' \
                                 'does not exist\n'.format(input_wav,
                                                           input_file))
                sys.exit(1)


            # Create the wave object:
            try:
                wave_in = wave.open(input_wav, 'r')
            except wave.Error as err:
                sys.stderr.write('Wrong format for input wavefile {0} ' \
                                 '({1})\n'.format(input_wav, err))
                sys.exit(1)

            extract_wave_chunks(chunk_list, wave_in, args.output_wav_dir)

            wave_in.close()


    output_f.close()


if __name__ == '__main__':
    main()
