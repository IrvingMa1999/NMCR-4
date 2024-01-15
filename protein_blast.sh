#!/bin/bash

# Usage: bash blast_script.sh <protein_sequences_dir> <query_sequences.fasta> <output_directory>
# Ensure that makeblastdb, blastp, seqkit, and sed are installed and in your PATH.

# Assign the command line arguments to variables
PROTEIN_SEQS_DIR=$1
QUERY_SEQS=$2
OUTPUT_DIR=$3

# Check if output directory exists, if not, create it
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Concatenate all faa files into one file for further processing
echo "Concatenating all .faa files..."
cat "${PROTEIN_SEQS_DIR}"/*.faa > "${OUTPUT_DIR}/all_proteins.faa"

# Modify the headers to only include the Gene ID using sed,
# and deduplicate the sequences with seqkit
echo "Modifying headers and deduplicating sequences..."
sed -i 's/>.*/>&/' "${OUTPUT_DIR}/all_proteins.faa" | \
sed -i 's/.*\(\>GeneID:[0-9]*\).*/\1/' "${OUTPUT_DIR}/all_proteins.faa" | \
seqkit rmdup -s -o "${OUTPUT_DIR}/all_proteins_dedup.faa" "${OUTPUT_DIR}/all_proteins.faa"

# Base name for the database
DB_NAME="protein_db"

# Step 1: Construct the BLAST database from protein sequences
echo "Building BLAST database..."
makeblastdb -in "${OUTPUT_DIR}/all_proteins_dedup.faa" -dbtype prot -out "${OUTPUT_DIR}/${DB_NAME}"

# Step 2: Run blastp with the query sequences against the constructed database
echo "Running blastp..."
blastp -query "$QUERY_SEQS" -db "${OUTPUT_DIR}/${DB_NAME}" -out "${OUTPUT_DIR}/blast_results.txt"  -outfmt 6 -num_alignments 100000

echo "BLAST search completed."