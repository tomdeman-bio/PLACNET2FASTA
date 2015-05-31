#!/usr/bin/perl

use strict;
use Getopt::Long;
use Array::Utils qw(:all);

my $placnet_csv = "";
my $plasmid_fasta = "";
my $original_fasta = "";
my %placnet_contig_plasmid_link;

GetOptions('csv=s'	=>\$placnet_csv,
		   'headers=s'	=>\$plasmid_fasta,
		   'fasta=s'	=>\$original_fasta);
		   
&Use unless((-e $placnet_csv) &&(-e $plasmid_fasta) &&(-e $original_fasta));

open CSV, "$placnet_csv" || die "cannot open $placnet_csv for reading";
open PLA, "$plasmid_fasta" || die "cannot open $plasmid_fasta for reading";
open FAS, "$original_fasta" || die "cannot open $original_fasta for reading";

#calling the main subroutines and generate main variables
my ($keys_dict, $plasmids_in_output) = &make_hashs;
my @contigIDs_of_plasmids = &overlap_detection;
&create_plasmid_contigs;

sub make_hashs {
	
	#create plasmid FASTA header hash
	my %plasmid_dict;
	while (<PLA>) {
		chomp;
		my @split_headers = split(/\|/, $_);
		$split_headers[0] =~ s/^.//;
		my $accession = "$split_headers[0]"."|"."$split_headers[1]"."|"."$split_headers[2]"."|"."$split_headers[3]"."|";
		my $organism = "$split_headers[4]";
		$plasmid_dict{$accession} = $organism;
	}
	close PLA;

	#store the keys from the plasmid header hash in an array
	my @keys = keys %plasmid_dict;

	#parse the placnet .csv output file
	my @plasmids;
	while (<CSV>) {
		chomp;
		my @split_csv = split ("\t", $_);
		push (@plasmids, $split_csv[1]);
		$placnet_contig_plasmid_link{$split_csv[1]} = $split_csv[0];
	}
	close CSV;
	
	return (\@keys, \@plasmids);
}

sub overlap_detection {
	
	#define overlap between @keys-dict and @plasmids_in_output
	my @overlap = intersect(@$keys_dict, @$plasmids_in_output);
	my @plasmid_contigs;
	foreach my $same (@overlap) {
		push (@plasmid_contigs, $placnet_contig_plasmid_link{$same});
	}

	my @unique_contigs = uniq(@plasmid_contigs);
	
	return @unique_contigs;
}

sub create_plasmid_contigs {
	my $name;
	my %hash;
	foreach my $id (@contigIDs_of_plasmids) {
		 $hash{$id}=1;
	}
	
	while (<FAS>) {
		chomp;
   		if (/>(\S+)/) {
       		$name=$1;
       		#print $name,"\n";
       		print $_."\n" if ($hash{$name});
   		}
   		else {
       		print $_."\n" if ($hash{$name});
   		}
	}
	close FAS;
	
}

sub uniq {
	my %hash;
	return grep { !$hash{$_}++ } @_;
}

sub Use {
	die "\n\tUsage::PLACNET2FASTA
	
	Written by Tom de Man
	
		-csv		The placnet .CSV output file
	
		-headers 	A file containing the plasmid FASTA headers, from the plasmid FASTA file used with placnet
	
		-fasta		The assembled contig file that served as placnet input
	\n";
}




