# CleanProMSA.sh

# Run within a directory that contains *.msa promoter alignments from compara

# Only take portions of alignment that include species of interest (human, chimp, macaque)
#!/bin/bash
files=*.msa
for f in $files
do
awk 'BEGIN {RS=""; FS = "\n"; ORS="\n\n"} /homo_sapiens/ && /pan_troglodytes/ && /macaca_mulatta/' < $f > $f.2
done


# Delete files that don't contain alignment for all 3 species:
find . -size 0 -delete


# Pull the first instance of each species within each record from each *.msa.2 and concatenate separately into a new file 
#!/bin/bash
files=*.msa.2
for f in $files
do
echo ">HUMAN" > $f.3
awk 'BEGIN {RS=""; FS = " "} /homo_sapiens/ {for(i=1;i<=NF;i++) if ($i~/homo_sapiens/) {print $(i+1); break}}' < $f >> $f.3
echo ">CHIMP" >> $f.3
awk 'BEGIN {RS=""; FS = " "} /pan_troglodytes/ {for(i=1;i<=NF;i++) if ($i~/pan_troglodytes/) {print $(i+1); break}}' < $f >> $f.3
echo ">MACAQUE" >> $f.3
awk 'BEGIN {RS=""; FS = " "} /macaca_mulatta/ { for(i=1;i<=NF;i++) if ($i~/macaca_mulatta/) {print $(i+1); break}}' < $f >> $f.3
done


# Remove positions with non-ACTG characters from each sequence
#!/bin/bash
files=*.3
for f in $files
do
python dashes.py $f > $f.clean
done

