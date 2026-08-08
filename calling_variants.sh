#!/bin/bash
set -euo pipefail

# for variant calling
module avail bcftools

# for variant calling
module avail freebayes

module load bcftools-1.14-gcc-11.2.0
module load freebayes-1.3.6-gcc-12.1.0

# Set variables for command line inputs
OUTPUTDIR="$1"		# Path to outpur dir
REF=$2				# Reference genome the sequence will be aligned to
PAIRED_READ_1=$3		# Paired read 1
PAIRED_READ_2=$4		# Paired read 2

echo "Aligning and Trimming.....$OUTPUTDIR"

bash paired_alignment_pipeline.sh "$OUTPUTDIR" "$REF" "$PAIRED_READ_1" "$PAIRED_READ_2"

echo "Calling variants using bcftools..."
# Determine the genotype likelihoods for each base.
bcftools mpileup -Ou -f $REF "$OUTPUTDIR/bwa_sorted.bam" | bcftools call --ploidy 1 -vm -Ov -o "$OUTPUTDIR/bcftools_variants.vcf"

echo "Calling variants using freebayes..."
freebayes -f $REF "$OUTPUTDIR/bwa_sorted.bam" > "$OUTPUTDIR/freebayes.vcf"
