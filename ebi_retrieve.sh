#!/bin/bash

# Author: @wezisendama
# 13/9/24

# If no command line argument specified, quit with error message
if [ -z "$1" ]; then echo "No metadata file specified!"; exit; fi

# Take metadata file (specified in argument) containing SRA accession numbers as input (format is the 
# comma-delimited metadata files from the SRA Run Selector) and read into array
IFS=$'\n'
sra_numbers=($(cut -d "," -f 1 $1 | tail -n +2))

# Iterate through items in array to get fastq filenames from EBI API. Check whether paired-end
# or single-end, then download both or the one

for sra_id in "${sra_numbers[@]}"; do
	fq_file1=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${sra_id}&result=read_run&fields=fastq_ftp" | cut -f 1 | tail -n +2 | cut -f 1 -d ";")
	fq_file2=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${sra_id}&result=read_run&fields=fastq_ftp" | cut -f 1 | tail -n +2 | cut -f 2 -d ";")
	
	if [[ "$fq_file1" == "$fq_file2" ]]; then echo "Downloading single-end fastq file..."; else echo "Downloading paired-end fastq files..."; fi
	
	wget $fq_file1
	
	if [[ "$fq_file1" == "$fq_file2" ]]; then continue; else wget $fq_file2; fi
	
done