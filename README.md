# Selection-Workflow
The scripts in this repository prepare the necessary files to test for positive selection in promoter regions of genes using the HyPhy batch file [nonCodingSelection.bf](https://github.com/ofedrigo/TestForPositiveSelection) written by Olivier Fedrigo. 

We use the scripts in this workflow to investigate selection in promoter regions of genes in primates (human, chimpanzee, and macaque), and perfom our analysis starting with a list of genes for which promoters will be tested and genomic data downloaded from the UCSC Table Browser (.gtf and .bed files). However, these scripts can be used generally to test for selection in non-coding regions of interest, or can be run individually to download alignment data from compara or for pre-processing data before selection testing.

## ID2bed&#46;sh
___
This script generates two bed files for selection testing: one file with promoter coordinates that will be tested for selection, and one "neutral" file with coordinates of non-coding regions in a 100kb window centered on each promoter that serves as a proxy for a neutral rate of nucleotide substitution.

### Detailed Summary
Starting with a list of UCSC gene IDs, transcription start sites are inferred for each gene based on the 5' most position in the 5' most exon described in the Gencode.gtf. These coordinates are used to build 5kb promoter windows. Portions of promoters overlapping gtf features are removed, and the remaining 3' most portions of size 500 bp or greater are written to promoters.bed with the gene ID for each promoter in the fourth column of the bed file.

To build coordinates representing neutrally evolving regions, 100kb windows centered on promoters are constructed, and first introns, exons, and promoters (for selection testing) are removed from the 100kb windows. Coordinates of the fragmented 100kb windows are then written to a bed file with the fourth column containing the promoter ID (on which the 100kb window is centered) with consecutive integer suffixes.

### Input Files
Filename |			Format
---------|-----------------------------------
GeneList.txt |				One-column list of UCSC Gene IDs 
Gencode.gtf |			GTF file downloaded from UCSC Table Browser
Gencode.Introns.bed |		Bed file of introns from UCSC Table Browser

### Output Files
Filename |			Format
---------|-----------------------------------
promoters.bed |   Bed file with unique ID in col #4
neutral.bed |    Bed file with unique ID in col #4

### Usage
./ID2bed.sh  

### Dependencies
bash shell  
bedtools  
unix utilities  
awk  

## fetchAlignment&#46;pl
___
This script takes a bed file as input, downloads sequence alignments from the compara API 6 primate EPO dataset, and outputs one file per record. The unique values in the fourth column of the bed file will be used to name each output file (eg "ID.msa").

### Detailed Summary
fetchAlignment&#46;pl should be used to collect alignments for promoter regions that will be tested for selection and for neutral regions associated with those promoters. Alignments are interleaved in ClustalW format and contain sequence alignment for all primates in the compara API 6 primate EPO dataset. Output files use gene IDs as root names to link neutral alignments with appropriate promoter alignments. Promoter and neutral alignments should be kept in separate directories because downstream processing of these files is handled differently for promoter and neutral alignments.

### Input Files
Filename |			Format
---------|-----------------------------------
promoters.bed |   Bed file with unique ID in col #4
neutral.bed |    Bed file with unique ID in col #4

### Output Files
Filename |			Format
---------|-----------------------------------
ID.msa |   ClustalW multiple sequence alignment. One file per promoter.
ID.x.msa |  ClustalW multiple sequence alignment. One or more files per neutral region.

### Usage  
perl fetchAlignment&#46;pl file.bed

### Dependencies
perl  
Ensembl perl API  

## cleanProMSA&#46;sh & dashes&#46;py
___
This script cleans promoter alignment files and produces files in aligned fasta format that are ready for use in the positive selection test.

### Detailed Summary
Run this script in a directory that contains all the promoter alignment files that need to be cleaned. Input files are processed to extract portions of alignments that contain sequences for 3 species of interest (human, chimpanzee, macaque). Files that do not contain alignments for all 3 species are removed. If multiple assemblies are aligned for a species, the first instance is preserved and later instances are removed. Interleaved sequence alignments are separated by species and printed in aligned fasta format. cleanProMSA&#46;sh works as a wrapper for dashes&#46;py to remove positions containing non-ACTG characters.  

### Input Files
Filename |			Format
---------|-----------------------------------
ID.msa | ClustalW multiple sequence alignment. One file per promoter.

### Output Files
Filename |			Format
---------|-----------------------------------
ID.msa.2.3.clean|   Aligned fasta format. One file per promoter.

### Usage  
./cleanProMSA.sh

### Dependencies
bash shell  
unix utilities  
awk  
python3  

## cleanNeutMSA&#46;sh & dashes&#46;py
___
This script cleans neutral alignment files and produces files in aligned fasta format that are ready for use in the positive selection test. This script differs from cleanProMSA&#46;sh in that multiple neutral .msa alignment files associated with an individual promoter are concatenated into a single file. Use and dependencies are the same as cleanProMSA&#46;sh & dashes&#46;py.

### Input Files
Filename |			Format
---------|-----------------------------------
ID.x.msa | ClustalW multiple sequence alignment. One or more files per neutral region per promoter.

### Output Files
Filename |			Format
---------|-----------------------------------
ID.cat.2.3.clean|   Aligned fasta format. One file per neutral region per promoter.

## selection&#46;sh
___
This script runs the [nonCodingSelection.bf](https://github.com/ofedrigo/TestForPositiveSelection) test for positive selection with HyPhy for all promoter/ neutral alignments. 

### Detailed Summary
To use this script, all promoter and neutral alignments should be in the same directory along with this script, a newick tree, and the file nonCodingSelection&#46;bf. This script creates a list of gene IDs that have both promoter and neutral alignments which is used to read files into HyPhy for processing through the HYPHYMP binary. Parameter settings in this script for running the selection test are:

Parameter | Setting
----------|--------
Neutral Proxy | Intronic sites  
Branch Specific | Yes  
Foreground Branch | Human  
Model Comparisons | Null2-Alternate2  
Empirical Bayes | Bayes Empirical Bayes  

### Input Files
Filename |			Format
---------|-----------------------------------
ID.cat.2.3.clean|   Aligned fasta format. One file per neutral region per promoter.
ID.msa.2.3.clean|   Aligned fasta format. One file per promoter.

### Output Files
Filename |			Format
---------|-----------------------------------
ID.out |   Report from selection test

### Usage
./selection.sh  

### Dependencies
bash shell  
unix utilities  
HyPhy
