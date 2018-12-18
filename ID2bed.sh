#!/bin/bash

##########################
#
# build 5kb promoter bed files
#
##########################
# GTF file tells us coordiate of 5' most exon. TSS starts 1bp 3' to this position.

# Create pos strand and neg strand GTFs.
# Sort such that the first instance contains the 5' most exon.
awk '$7 ~ /\+/' < Gencode.gtf | sort -k4,4 > Gencode.gtf.pos
awk '$7 ~ /\-/' < Gencode.gtf | sort -k5,5r > Gencode.gtf.neg
cat Gencode.gtf.pos Gencode.gtf.neg > Gencode.sorted
rm Gencode.gtf.pos
rm Gencode.gtf.neg

# for each ID in GeneList.txt, find matches, and pull the first match
#!/bin/bash
cat GeneList.txt | while read ID
do
grep -m1 $ID Gencode.sorted >> ID.GTF
done

# print bed file of 5kb promoters
awk -v OFS='\t' '{if ($7 == "+") {print $1, $4-5000, $4-1, $10, $7} else {print $1, $5+1, $5+5000, $10, $7}}' < ID.GTF | sed 's/"//g' | sed 's/;//g' > promoters.5kb.bed

rm ID.GTF

##########################
#
# remove sections of promoters that overlap with Ensembl genes
#
##########################
# make a bed file of gene coordinates
awk -v OFS='\t' '{print $1, $4, $5}' < Gencode.GTF > Gencode.bed

sort -k1,1 -k2,2n promoters.5kb.bed > promoters.5kb.bed.sorted
sort -k1,1 -k2,2n Gencode.bed > Gencode.bed.sorted
rm promoters.5kb.bed
rm Gencode.bed

# use bedtools to remove portions of promoters overlapping genes
bedtools subtract -a promoters.5kb.bed.sorted -b Gencode.bed.sorted > promoters.subtracted

# keep the 3' most portion of each promoter
# first do the neg strand
sort -k1,1 -k2,2n promoters.subtracted | awk '$5 ~ /\-/' | awk '!x[$4]++' > promoters
sort -k1,1 -k3,3nr promoters.subtracted | awk '$5 ~ /\+/' | awk '!x[$4]++' >> promoters

# filter by size n=1057
awk -v OFS='\t' '{ if ($3-$2+1 >= 500) {print $1, $2, $3, $4}}' < promoters > promoters.bed

rm promoters.5kb.bed.sorted
rm promoters.subtracted
rm promoters

##########################
#
# build 100kb (neutral proxy) bed file
#
##########################

# calculate 100kb coordinates centered on promoters
awk '{center=($3+$2)/2 ; start=center-50000 ; end=center+50000 ; printf "%s %.0f %.0f %s\n", $1, start, end, $4}' < promoters.bed | sort -k1,1 -k2,2n | tr ' ' '\t' > neutral.100kb.bed

# format intron file
tr '_' ' ' < Gencode.Introns.bed > Gencode.Introns.tab

sort -k1,1 -k2,2n Gencode.Introns.tab | awk '$12 ~ /\+/' | awk '!x[$4]++' > Gencode.first.introns

sort -k1,1 -k2,2nr -k3,3nr Gencode.Introns.tab | awk '$12 ~ /\-/' | awk '!x[$4]++' >> Gencode.first.introns

rm Gencode.Introns.tab

# cat together the non-neutral regions
cat promoters.bed Gencode.first.introns Gencode.bed.sorted | awk -v OFS='\t' '{print $1, $2, $3}' | sort -k1,1 -k2,2n > nonneutral

# remove exons and first introns (non-neutral regions) from the 100kb coords
bedtools subtract -a neutral.100kb.bed -b nonneutral > neutralregions.bed

# add .++n to $4 (to each ID) to create unique ID for each output file.
awk -v OFS='\t' '{x=++count[$4]; print $1, $2, $3, $4"\."x}' neutralregions.bed > neutral.bed

rm nonneutral
rm neutralregions.bed
rm neutral.100kb.bed
rm Gencode.first.introns
rm Gencode.bed.sorted
rm Gencode.sorted