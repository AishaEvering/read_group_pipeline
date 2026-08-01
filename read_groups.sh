#!/bin/bash

merged_inputs=()

load_modules(){
	echo "Loading required modules...."
	module load bwa-0.7.17-gcc-12.1.0
	module load samtools-1.9-gcc-12.1.0
}

index_reference(){
	local ref="$1"
	echo "Indexing reference genome: $ref..."
	bwa index "$ref"
}

get_sample_name(){
 local FULL_SAMPLE_PATH="$1"

 # Remove the path
 filename="${FULL_SAMPLE_PATH##*/}"

 # Remove the paired read suffix
 echo "${filename%_1.fastq}"
}

align_samples(){
	local ref="$1"
	local read1="$2"
	local read2="$3"
	local output="$4"

	# Align sample
	bwa mem "$ref" "$read1" "$read2" > "$output"
}

create_indexed_BAM(){
	local sam_input="$1"
	local bam_output="$2"

	echo "Creating and indexing BAM: $bam_output"
	samtools sort "$sam_input" > "$bam_output"
	samtools index "$bam_output"
}

add_read_groups(){
	local sample="$1"
	local bam_input="$2"
	local rg_bam_output="$3"

	echo "Adding read group to: $rg_bam_output"
	samtools addreplacerg -r "@RG\tID:${sample}\tSM:${sample}" -o "$rg_bam_output" "$bam_input"
}

merge_bams(){
	
	local outputdir="$1"
	
 	samtools merge "$outputdir/merged.bam" "${merged_inputs[@]}"
	samtools index "$outputdir/merged.bam"
}

process_samples(){
	local ref="$1"
	local outputdir="$2"
	shift 2


	while (( $# > 0 ))
	do
		local read1="$1"
		local read2="$2"
		local sample
		local bam_output
		local rg_bam

		# Extract sample name

		sample=$(get_sample_name "$read1")
		
		sam_output="$outputdir/${sample}.sam"
		bam_output="$outputdir/${sample}.bam"
		rg_bam="$outputdir/${sample}.rg.bam"

		echo "Processing sample: $sample"
		echo "Read 1: $read1"
		echo "Read 2: $read2"


		echo "Aligning $sample..."
		align_samples "$ref" "$read1" "$read2" "$sam_output"

		create_indexed_BAM "$sam_output" "$bam_output"
		add_read_groups "$sample" "$bam_output" "$rg_bam"

		merged_inputs+=("$rg_bam")

		shift 2
	done
}


main() {
       echo "Starting Read Group Practice..."
       
       if (( $# < 4)); then
	       echo "Usage: $0 reference.fa output_directory read1.fastq read2.fastq [additional pairs....]"
	       exit 1
       fi
       
       local ref="$1"		# Path to the reference genome
       local outputdir="$2"    # Path to the output dir
       
       # Remove the reference and output directory from the argument
       shift 2
       
       # make sure output directory exist
       mkdir -p "$outputdir"

       # Make sure the remaining arguments come in pairs
       if (( $# % 2 !=0 )); then
	       echo "Error: FASTQ files must be provided as read 1/read 2 pairs."
	       exit 1
       fi

       load_modules
       index_reference "$ref"
       process_samples "$ref" "$outputdir" "$@"

       # Merge and index merged BAM
       merge_bams "$outputdir"
}

main "$@"

