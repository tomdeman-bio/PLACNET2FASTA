# PLACNET2FASTA

PLACNET can be obtained from http://sourceforge.net/projects/placnet/

## This script needs three input files

1. The placnet .net.csv file 
2. A FASTA header file containing sequence headers from plasmids only (example header file is included with this script)
3. The assembled contig or scaffold file that was used as input for placnet

## How to generate the plasmid FASTA header file?

Plasmid sequences can be downloaded at: ftp://ftp.ncbi.nlm.nih.gov/genomes/Plasmids/

Concatenate all plasmid sequences into one big file and name it “NCBI-plasmid.fasta”

The FASTA header file can be generated using “grep ‘>’ NCBI-plasmid.fasta > header-file.txt”
