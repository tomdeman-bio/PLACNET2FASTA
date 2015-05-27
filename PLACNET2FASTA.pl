#!/usr/bin/perl

use strict;
use Array::Utils qw(:all);

my $placnet_csv = shift;
my $plasmid_fasta = shift;

open CSV, "$placnet_csv" || die "cannot open $placnet_csv for reading";
open PLA, "$plasmid_fasta" || die "cannot open $plasmid_fasta for reading";

#create plasmid header hash
my %plasmid_dict;
while (<PLA>) {
	chomp;
	my @split_headers = split(/\|/, $_);
	$split_headers[0] =~ s/^.//;
	my $accession = "$split_headers[0]"."|"."$split_headers[1]"."|"."$split_headers[2]"."|"."$split_headers[3]"."|";
	my $organism = "$split_headers[4]";
	$plasmid_dict{$accession} = $organism;
}

#store the keys from the plasmid header hash in an array
my @keys_dict = keys %plasmid_dict;

#parse the placnet .csv output file
my @plasmids_in_output;
my %placnet_contig_plasmid_link;
while (<CSV>) {
	chomp;
	my @split_csv = split ("\t", $_);
	push (@plasmids_in_output, $split_csv[1]);
	$placnet_contig_plasmid_link{$split_csv[1]} = $split_csv[0];
}

#define overlap between @keys-dict and @plasmids_in_output
my @overlap = intersect(@keys_dict, @plasmids_in_output);
my @plasmid_contigs;
foreach my $same (@overlap) {
	push (@plasmid_contigs, $placnet_contig_plasmid_link{$same});
}

my @unique_contigs = uniq(@plasmid_contigs);
foreach my $contigs (@unique_contigs) {
	print $contigs."\n";
}

sub uniq {
	my %hash;
	return grep { !$hash{$_}++ } @_;
}
	
	