use strict;
use warnings;
use Data::Dumper;

if (@ARGV != 1) {
	die "Usage: output_tables.pl <sample_summary.txt>\n";
}

open(IN, $ARGV[0]) or die "ERROR: Cannot open $ARGV[0]: $!\n";
my @file = <IN>; chomp @file;

open(P_OUT, ">output/person_table.csv") or die "ERROR: Cannot create file: $!\n";
open(S_OUT, ">output/specimen_table.csv") or die "ERROR: Cannot create file: $!\n";
open(PRO_OUT, ">output/provider_table.csv") or die "ERROR: Cannot create file: $!\n";
open(A_OUT, ">output/assay_occurrence.csv") or die "ERROR: Cannot create file: $!\n";
open(AD_OUT, ">output/assay_occurrence_data.csv") or die "ERROR: Cannot create file: $!\n";
open(AP_OUT, ">output/assay_parameters.csv") or die "ERROR: Cannot create file: $!\n";
open(C_OUT, ">output/condition_occurence.csv") or die "ERROR: Cannot create file: $!\n";

my $people_header = "person_id,gender_concept_id,person_source_value,gender_source_value\n";
my $specimen_header = "specimen_id,specimen_source_value,specimen_type_source_value,person_id\n";
my $provider_header = "provider_id,provider_source_value,provider_type_source_value,person_id\n";
my $assay_occurrence_header = "assay_occurrence_id,specimen_source_value,assay_start_date,assay_source_value,assay_type_source_value,specimen_id\n";
my $assay_occurrence_data_header = "assay_occurrence_data_id,file_source_value,specimen_id\n";
my $assay_parameters_header = "assay_parameters_id,reference_source_value,reference_genome_value,specimen_id\n";
my $condition_occurence_header = "condition_occurence_id,condition_type_value,person_id\n";

print P_OUT "$people_header";
print S_OUT "$specimen_header";
print PRO_OUT "$provider_header";
print A_OUT "$assay_occurrence_header";
print AD_OUT "$assay_occurrence_data_header";
print AP_OUT "$assay_parameters_header";
print C_OUT "$condition_occurence_header";


my %gender_concept_id = (
   male => 8507,
   female => 8532,
   NA => 8551
);

my $count = 1;
# initialize table column variables with 0 as default ( 0's represent unknown)
my($gender_cid, $person_source_value, $gender_source_value) = (0, 0, 0); # person
my($specimen_id, $specimen_source_value, $specimen_type_source_value) = (0, 0, 0); # specimen
my($provider_id, $source_name, $source_value) = (0, "GEO", "GSE60682"); # source provider (# ideally should be in the input file)
my($assay_occurrence_id, $assay_start_date, $assay_source_value, $assay_type_source_value) = (0, 0, 0, 0);
my($assay_occurrence_data_id, $file_source_value) = (0, 0); # 
my($assay_parameters_id, $reference_source_value, $reference_genome_value) = (0, 0, 0); # 
my($condition_occurence_id, $condition_type_value) = (0, 0); # 

# initialize unique id's for tables
my %person_id;
my %condition_id;

# initialize which condition to filter
my $condition = "cutaneous T cell leukemia (CTCL)";

foreach my $line (@file) {
	next if ($line =~ /^ID/); # skip header
	my @array = split(/\t/, $line);

	## people and provider table values
	# check if we are repeating patient id's
	if (!exists $person_id{$array[1]}) {

		# people table
		$person_id{$array[1]}++;
		$gender_cid = $gender_concept_id{$array[13]}; # gender concept id
		$person_source_value = $array[2]; # patient name as from source
		$gender_source_value = $array[13]; # gender name as from source
		print P_OUT "$array[1],$gender_cid,$person_source_value,$gender_source_value\n";

		# provider table
		$provider_id= "P$array[1]";
		print PRO_OUT "$provider_id,$source_name,$source_value,$array[1]\n"; 

	}

	# join patient_id and condition for creating a unique key
	my $patient_condition = join('_', $array[12],$array[1]);
	## condition_occurence table
	if ((!exists $condition_id{$patient_condition}) and $array[12] =~ /CTCL/) {
		$condition_id{$patient_condition}++;
		$condition_occurence_id = "C$array[1]";
		print C_OUT "$condition_occurence_id,$array[12],$array[1]\n";
	}

	# initialize unique id's for all tables
	$assay_occurrence_id = "A$array[0]";
	$assay_occurrence_data_id = "AD$array[0]";
	$assay_parameters_id = "AD$array[0]";
	$specimen_id = "S$array[0]";

	## specimen table values
	$specimen_source_value = $array[5];
	$specimen_type_source_value = $array[14];
	print S_OUT "$specimen_id,$specimen_source_value,$specimen_type_source_value,$array[1]\n";

	## assay_occurrence table values
	$assay_start_date = $array[16];
	$assay_source_value = $array[6];
	$assay_type_source_value = $array[7];

	# format time stamps
	if ($assay_start_date =~ /hrs/) {
		$assay_start_date =~ s/hrs//;
		$assay_start_date = "$assay_start_date:00:00";
	}
	if ($assay_start_date =~ /Day/) {
		$assay_start_date =~ s/Day//;
		$assay_start_date = "$assay_start_date-00:00:00";
	}

	print A_OUT "$assay_occurrence_id,$specimen_source_value,$assay_start_date,$assay_source_value,$assay_type_source_value,$specimen_id\n";

	## assay_occurrence_data table values
	$file_source_value = $array[17];
	print AD_OUT "$assay_occurrence_data_id,$file_source_value,$specimen_id\n";

	## assay_parameters table values
	$reference_source_value = $array[9];
	$reference_genome_value = $array[18];
	print AP_OUT "$assay_parameters_id,$reference_source_value,$reference_genome_value,$specimen_id\n";

	

}