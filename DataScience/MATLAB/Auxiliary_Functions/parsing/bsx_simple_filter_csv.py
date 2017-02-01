#!/bin/python
import os
import sys

# Initializations
inFileName = sys.argv[1]
outFileName = sys.argv[2]
CONT_FLAG = False   # Continuation flag. Stops checking for empty lines once its set to True

IS_20HZ_BUG = False
lastLineImu20Hz = False
lastLineOptical = ""

# Processing
infile = open(inFileName, 'r')
out_file = open(outFileName, 'w')

for line_number, line in enumerate(infile, 1):
    if line_number <= 3 :
        out_file.write(line.strip() + "\n")
        if line_number == 2:
            fields = line.split(',')
            if fields[1] == "20" and fields[2] == "20" and (fields[7] == "2.1.195" or fields[7] == "2.1.196"):
                IS_20HZ_BUG = True
    else :
        if IS_20HZ_BUG :
            if line.startswith(",,,,,,,,,,,,,,,,,,,") and not line.strip(",").strip() == "" :
                if lastLineImu20Hz :
                    out_line = lastLineOptical
                    out_line = out_line.replace("-Infinity", "NaN") 	# Check for -Infinity first.
                    out_line = out_line.replace("Infinity", "NaN")
                    out_file.write(out_line.strip() + "\n")
                lastLineImu20Hz = True
            elif not line.startswith(",,,,,,,,,,,,,,,,,,,") :
                lastLineOptical = line
                lastLineImu20Hz = False
        if CONT_FLAG == False and line.startswith(",,"):
            continue
        else :
            CONT_FLAG = True 	# We are done checking for empty lines


        out_line = line
        out_line = out_line.replace("-Infinity", "NaN") 	# Check for -Infinity first.
        out_line = out_line.replace("Infinity", "NaN")
        out_file.write(out_line.strip() + "\n")
