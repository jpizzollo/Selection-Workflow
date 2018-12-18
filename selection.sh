#!/bin/bash

# get list of IDs shared between promoter and neutral
ls *msa*clean | tr '.' '\t' | awk '{print $1"."$2}' > IDpro
ls *cat*clean | tr '.' '\t' | awk '{print $1"."$2}' > IDneut
join IDpro IDneut > sharedIDs

###############################################
#
#		HYPHYMP nonCodingSelection.bf
#
###############################################

#	Promoters:	$line.msa.2.3.clean
#	Neutral:	$line.cat.2.3.clean

for line in $(cat sharedIDs)
do
HYPHYMP nonCodingSelection.bf << VARS > $line.out
2
$line.cat.2.3.clean
tree
2
1
$line.msa.2.3.clean
2
1
VARS
done