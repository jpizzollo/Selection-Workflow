#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Bio::AlignIO;
use Bio::EnsEMBL::Registry;

# Auto-configure the registry
Bio::EnsEMBL::Registry->load_registry_from_db(
	-host=>"ensembldb.ensembl.org", -user=>"anonymous",
        -port=>'5306');

# Get the Compara Adaptor for MethodLinkSpeciesSets
my $method_link_species_set_adaptor =
     Bio::EnsEMBL::Registry->get_adaptor(
       "Multi", "compara", "MethodLinkSpeciesSet");

my $methodLinkSpeciesSet = $method_link_species_set_adaptor->
         fetch_by_method_link_type_species_set_name("EPO", "primates");

# Get the reference species *core* Adaptor for Slices
my $ref_slice_adaptor =
     Bio::EnsEMBL::Registry->get_adaptor(
       "homo_sapiens", "core", "Slice");

# Bring in the bed file and make an array of rows
my $file = $ARGV[0];
open(my $profh, '<:encoding(UTF-8)', $file)
  or die "Could not open file '$file' $!";
my @row = <$profh>;

# Count rows in the file
my $count = `wc -l < $file`;

# Loop through Rows, pulling Chr, Start, END, and ENSID
for (my $i=0; $i < $count; $i++){
my $data = $row["$i"];
my @values = split(' ', $data);
my $chr = $values[0];
my $start = $values[1];
my $end = $values[2];
my $ID = $values[3];

# Get the slice corresponding to the region of interest
my $ref_slice = $ref_slice_adaptor->fetch_by_region(
     "chromosome", $chr, $start, $end);

# Get the Compara Adaptor for GenomicAlignBlocks
my $genomic_align_block_adaptor =
     Bio::EnsEMBL::Registry->get_adaptor(
       "Multi", "compara", "GenomicAlignBlock");

# The fetch_all_by_MethodLinkSpeciesSet_Slice() returns a ref.
# to an array of GenomicAlingBlock objects (human is the reference species)
my $all_genomic_align_blocks = $genomic_align_block_adaptor->
     fetch_all_by_MethodLinkSpeciesSet_Slice(
         $methodLinkSpeciesSet, $ref_slice);

# set up an AlignIO to format SimpleAlign output
open my $MYOUT, '>', "$ID.msa";

my $alignIO = Bio::AlignIO->newFh(-interleaved => 0,
                                   -fh => $MYOUT,
                                   -format => 'clustalW',
                                   -idlength => 30);

# print the restricted alignments

foreach my $genomic_align_block( @{ $all_genomic_align_blocks }) {
         my $restricted_gab = 
$genomic_align_block->restrict_between_reference_positions($start, 
$end);
	eval {$restricted_gab->get_SimpleAlign;
  	      };
	if ($@) {print "Error in $ID\n";
	} else {print $alignIO $restricted_gab->get_SimpleAlign;
}
}

close $MYOUT;}

