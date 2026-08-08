#!/bin/bash
# WHAT: This program will run fastqc and trimmomatic on a single end sequence file
# HOW: Input the path to your SE sequence data and the path to your output
# directories.  Then list the output file name you want for the output of
# trimmomatic.  Then, the program will run fastqc on the raw data, it will
# run trimmomatic, then it will run fastqc on the trimmed data.


# Set variables for three comman line standard inputs
SEQUENCE=$1	 # First command line input
		 # This is the path to sequencing data.  Could be:
		 # illumina SE sequencing data - e.g., /data/compres/seq_platform_data/illumina.fq
		 # pacbio SE sequencing data
		 # minion SE sequencing data
		 # iontorrent SE sequencing data
OUTPUTDIR=$2	 # path to outputdir - e.g., /home/ASUrite/BIO439/module4/
OUTPUTFILE=$3	 # name of trimmed file = e.g., illumina_trimmed.fq

echo $OUTPUTDIR$OUTPUTFILE

#######
# Step 1
######
# load fastqc on the cluster and run fastqc on each file
module load fastqc-0.11.9-gcc-12.1.0
fastqc $SEQUENCE -o $OUTPUTDIR

#######
# Step 2
#######
# load trimmomatic then run trimmomatic on the raw sequence data
module load trimmomatic-0.39-gcc-12.1.0
trimmomatic SE $SEQUENCE $OUTPUTDIR$OUTPUTFILE SLIDINGWINDOW:4:30

#######
# Step 3
#######
# run fastqc on the trimmed data
fastqc $OUTPUTDIR$OUTPUTFILE -o #OUTPUTDIR
