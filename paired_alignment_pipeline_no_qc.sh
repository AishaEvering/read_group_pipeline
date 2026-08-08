#!/bin/bash
# This program will retrieve raw data, view the quality of the data,
# trim the quality of the data using timmomatic with SLIDINGWINDOW:4:30,
# view the qualilty of the trimmed data, align the trimmed data using bwa,
# sort and view the bam data.

# Set variables for command line inputs
OUTPUTDIR="./$1"		# Path to output dir
REF=$2			# Reference genome the sequence will be aligned to
PAIRED_READ_1=$3	# Paired read 1
PAIRED_READ_2=$4	# Paried read 2
TRIMMED_PAIRED_READ_1="$OUTPUTDIR/${5:-trimmed_paired_1.fastq}"	# Optional paired 1 trimmed file
TRIMMED_PAIRED_READ_2="$OUTPUTDIR/${6:-trimmed_paired_2.fastq}"	# Optional paired 2 trimmed file
TRIMMED_UNPAIRED_READ_1="$OUTPUTDIR/${7:-trimmed_unpaired_1.fastq}"	# Optional unpaired 1 trimmed file
TRIMMED_UNPAIRED_READ_2="$OUTPUTDIR/${8:-trimmed_unpaired_2.fastq}"	# Optional unpaired 2 trimmed file
SORTED_BAM_OUTPUT_FILE="$OUTPUTDIR/${9:-bwa_sorted.bam}"	# Optional name of the outputted sorted bam file

echo "Processing raw paired end files: " \
	"$PAIRED_READ_1 and $PAIRED_READ_2"

# make sure output directory exist
mkdir -p "$OUTPUTDIR"

#######
# Step 1
#######
# load fastqc on the cluster and run fastqc 
#module load fastqc-0.11.9-gcc-12.1.0
#echo "Running FastQC on paired ends: $PAIRED_READ_1 and $PAIRED_READ_2"
#fastqc \
#	"$PAIRED_READ_1" \
#        "$PAIRED_READ_2" \
#	-o "$OUTPUTDIR"

#######
# Step 2
#######
# load trimmomatic then run trimmatic on the paired end reads
#module load trimmomatic-0.39-gcc-12.1.0
#echo "Running Trimmomatic paired reads: $PAIRED_READ_1 and $PAIRED_READ_2"
#trimmomatic PE "$PAIRED_READ_1" "$PAIRED_READ_2" \
#       "$TRIMMED_PAIRED_READ_1" \
#       "$TRIMMED_UNPAIRED_READ_1" \
#       "$TRIMMED_PAIRED_READ_2" \
#       "$TRIMMED_UNPAIRED_READ_2" SLIDINGWINDOW:4:30

#######
# Step 3
#######
# run fastqc on the trimmed paired ends
#echo "Running FastQC on trimmed paired ends: $TRIMMED_PAIRED_READ_1 and $TRIMMED_PAIRED_READ_2"
#fastqc "$TRIMMED_PAIRED_READ_1" "$TRIMMED_PAIRED_READ_2" -o "$OUTPUTDIR"

#######
# Step 4
#######
# index reference genome
module load bwa-0.7.17-gcc-12.1.0
echo "Indexing reference genome: $REF"
bwa index $REF

#######
# Step 5
#######
# aligning paired-end reads and sort and
# pipe output to samtools to sort into a BAM file and save output as bwa.bam
module load samtools-1.9-gcc-12.1.0
echo "Aligning paired end reads and sorting into $SORTED_BAM_OUTPUT_FILE"
bwa mem "$REF" "$PAIRED_READ_1" "$PAIRED_READ_2" | 
       samtools sort -o "$SORTED_BAM_OUTPUT_FILE"


#######
# Step 6
#######
# index the BAM file
#echo "Indexing $SORTED_BAM_OUTPUT_FILE"
samtools index "$SORTED_BAM_OUTPUT_FILE"

echo "Alignment statistics"
samtools flagstat "$SORTED_BAM_OUTPUT_FILE"

echo ""
echo "Detailed alignment statistics:"
samtools stats "$SORTED_BAM_OUTPUT_FILE"


#######
# Step 7
#######
# View the firstn 10 alignments in the sorted BAM file
#echo "Viewing first 10 alignments in $SORTED_BAM_OUTPUT_FILE"
#samtools view "$SORTED_BAOUTPUT_FILE" | head -10
