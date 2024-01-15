#!/bin/bash

# Usage: bash sequence_processing.sh <input_directory> <output_directory>
# Ensure fastqc, Nanoplot, fastp, Filtlong, and Unicycler are installed and in your PATH.

# Define input and output directories
INPUT_DIR=$1
OUTPUT_DIR=$2

# Create the output directories if they don't exist
mkdir -p "${OUTPUT_DIR}/fastqc"
mkdir -p "${OUTPUT_DIR}/nanoplot"
mkdir -p "${OUTPUT_DIR}/fastp"
mkdir -p "${OUTPUT_DIR}/filtlong"
mkdir -p "${OUTPUT_DIR}/assembly"

# Step 1: Quality check with FastQC
echo "Starting quality check with FastQC..."
for file in "${INPUT_DIR}"/*.fastq.gz; do
    echo "Running FastQC on $(basename "$file")"
    fastqc "$file" --outdir="${OUTPUT_DIR}/fastqc"
done

# Quality check with Nanoplot
echo "Starting quality check with NanoPlot..."
for file in "${INPUT_DIR}"/*.fastq.gz; do
    echo "Running NanoPlot on $(basename "$file")"
    NanoPlot --fastq "$file" --outdir "${OUTPUT_DIR}/nanoplot" --prefix "$(basename "$file" .fastq.gz)"
done

# Step 2: Quality and length filtering with fastp and Filtlong
echo "Starting quality and length filtering with fastp and Filtlong..."
for file in "${INPUT_DIR}"/*.fastq.gz; do
    # Assuming single-end reads for Filtlong, adjust accordingly for paired-end reads
    base=$(basename "$file" .fastq.gz)
    echo "Running fastp on ${base}"
    
    fastp -i "$file" \
          -o "${OUTPUT_DIR}/fastp/${base}.fastp.fastq.gz" \
          --html "${OUTPUT_DIR}/fastp/${base}.fastp.html" \
          --json "${OUTPUT_DIR}/fastp/${base}.fastp.json"
    
    echo "Running Filtlong on ${base}"
    filtlong --min_length 1000 --keep_percent 90 \
             "${OUTPUT_DIR}/fastp/${base}.fastp.fastq.gz" > "${OUTPUT_DIR}/filtlong/${base}.filtlong.fastq.gz"
done

# Step 3: Assembly with Unicycler
echo "Starting assembly with Unicycler..."
for file in "${OUTPUT_DIR}/filtlong/"*.filtlong.fastq.gz; do
    base=$(basename "$file" .filtlong.fastq.gz)
    echo "Assembling ${base} with Unicycler"
    
    unicycler -l "$file" \
              -o "${OUTPUT_DIR}/assembly/${base}"
done

echo "All processing steps completed."