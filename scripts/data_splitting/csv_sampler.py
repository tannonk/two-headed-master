#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""sample random lines from csv file for dev set"""

import sys
import random
import csv

infile = sys.argv[1]
outfile1 = sys.argv[2]
outfile2 = sys.argv[3]
split_len = int(sys.argv[4])

def knuth(infile, train_out, dev_out, n):
    """
    Applies Knuth's R algorithm to split a corpus of unknown length into a split, with a reservoir of size n.
    Params:
        iterable, path = target directory file path, n = size of reservoir.
    Effects:
        splits input file into two split files
    """

    with open(infile, 'r', encoding='utf8') as inf, open(train_out, 'w') as train, open(dev_out, 'w') as dev:
        reader = csv.reader(inf, delimiter=',')
        train_writer = csv.writer(train, delimiter=',')
        dev_writer = csv.writer(dev, delimiter=',')

        reservoir = []
        # For each token in sentence, apply the knuth algorithm.
        for idx, row in enumerate(reader):

            if idx == 0:
                train_writer.writerow(row)
                dev_writer.writerow(row)

            # If index is less than the number of items in the reservoir, add the item to the reservoir.
            if idx < n:
                reservoir.append(row)
            # If index is larger than number of items in reservoir, generate a random number between 0 and the item's index.
            else:
                reservoir_idx = random.randint(0, idx)
                # If generated number is smalled than size of reservoir, remove existing item in reservoir at that index, write it to traing file and append the newly processed item.
                if reservoir_idx < n:
                    # Write training data to file.
                    train_writer.writerow(reservoir.pop(reservoir_idx))
                    # reservoir[reservoir_idx] = item
                    reservoir.append(row)
                else:
                    # Write training data to file.
                    train_writer.writerow(row)

        # write all items in reservoir to split set
        for row in reservoir:
            dev_writer.writerow(row)

def main():
    knuth(infile, outfile1, outfile2, split_len)


if __name__ == '__main__':
    main()
