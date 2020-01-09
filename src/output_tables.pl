use strict;
use warnings;
use File::Basename;
use Data::Dumper;

if (@ARGV != 1) {
	die "Usage: output_tables.pl <sample_summary.txt>\n";
}

open(IN, $ARGV[0]) or die "ERROR: Cannot open $ARGV[0]: $!\n";
my @file = <IN>; chomp @file;

open(P_OUT, ">Tables/person_table.txt") or die "ERROR: Cannot create file: $!\n";
open(S_OUT, ">Tables/specimen_table.txt") or die "ERROR: Cannot create file: $!\n";
open(SP_OUT, ">Tables/source_provider_table.txt") or die "ERROR: Cannot create file: $!\n";

my $people_header = "person_id\tgender_concept_id\tperson_source_value\tgender_source_value\n";
my $specimen_header = "disease_status_source_value\ttreatment_source_value\tcell_type_source_value\tperson_id\n";
my $source_provider_header = "source_id\tsource_name\tsource_value\tperson_id\n";

print P_OUT "$people_header";
print S_OUT "$specimen_header";
print SP_OUT "$source_provider_header";

my $count = 1;
my %gender_concept_id = (
   male => 8507,
   female => 8532,
   NA => 8551
);

my $source_name = "GEO";
my $source_value = "GSE60682";

# initialize table column variables
my($gender_cid, $person_source_value, $gender_source_value) = (0, 0, 0); # person
my($disease_status_source_value, $treatment_source_value, $cell_type_source_value, $person_id) = (0, 0, 0, 0); # specimen
my($source_id, $source_name, $source_value) = (0, 0, 0); # person

foreach my $line (@file) {
	next if ($line =~ /^file_name/); # skip header
	my @array = split(/\t/, $line);

	my $pid = "P$count";
	print P_OUT "P$count\t$gender_concept_id{$array[8]}\t$array[1]\t$array[8]\n";
	print S_OUT "$array[7]\t$array[10]\t$array[9]\tP$count\n";
	print SP_OUT "S1\t$source_name\t$source_value\tP$count\n"; # ideally should be in the input file

	$count++;
}