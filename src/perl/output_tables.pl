use strict;
use warnings;
use Data::Dumper;

if (@ARGV != 2) {
	die "Usage: perl output_tables.pl <sample_summary.tsv> <output_dir>\n";
}

open(IN, $ARGV[0]) or die "ERROR: Cannot open $ARGV[0]: $!\n";
my @file = <IN>; chomp @file;

system("mkdir -p $ARGV[1]"); # create a output folder to write tables
open(P_OUT, ">$ARGV[1]/person_table.csv") or die "ERROR: Cannot create file: $!\n";
open(S_OUT, ">$ARGV[1]/specimen_table.csv") or die "ERROR: Cannot create file: $!\n";
open(PRO_OUT, ">$ARGV[1]/provider_table.csv") or die "ERROR: Cannot create file: $!\n";
open(A_OUT, ">$ARGV[1]/assay_occurrence.csv") or die "ERROR: Cannot create file: $!\n";
open(AD_OUT, ">$ARGV[1]/assay_occurrence_data.csv") or die "ERROR: Cannot create file: $!\n";
open(AP_OUT, ">$ARGV[1]/assay_parameters.csv") or die "ERROR: Cannot create file: $!\n";
open(C_OUT, ">$ARGV[1]/condition_occurrence.csv") or die "ERROR: Cannot create file: $!\n";
open(PE_OUT, ">$ARGV[1]/perturbation.csv") or die "ERROR: Cannot create file: $!\n";


my $people_header = "person_id,gender_concept_id,person_source_value,gender_source_value\n";
my $specimen_header = "person_id,specimen_id,specimen_source_value,specimen_type_source_value\n";
my $provider_header = "person_id,provider_id,provider_source_value,provider_type_source_value\n";
my $assay_occurrence_header = "specimen_id,assay_occurrence_id,specimen_source_value,assay_start_date,assay_source_value,assay_type_source_value\n";
my $assay_occurrence_data_header = "specimen_id,assay_occurrence_data_id,file_source_value\n";
my $assay_parameters_header = "specimen_id,assay_parameters_id,reference_source_value,reference_genome_value\n";
my $condition_occurence_header = "person_id,condition_occurence_id,condition_type_value\n";
my $perturbation_header = "specimen_id,perturbation_id,perturbation_source_value,perturbation_type_source_value,pereturbation_start_date,perturbation_dose_value_as_number,perturbation_dose_unit\n";


print P_OUT "$people_header";
print S_OUT "$specimen_header";
print PRO_OUT "$provider_header";
print A_OUT "$assay_occurrence_header";
print AD_OUT "$assay_occurrence_data_header";
print AP_OUT "$assay_parameters_header";
print C_OUT "$condition_occurence_header";
print PE_OUT "$perturbation_header";

my %gender_concept_id = (
   male => 8507,
   female => 8532,
   "NA" => 8551
);

my $count = 1;
# initialize table column variables with 0 as default ( 0's represent unknown)
my($gender_cid, $person_source_value, $gender_source_value) = ("NA", "NA", "NA"); # person
my($specimen_id, $specimen_source_value, $specimen_type_source_value) = ("NA", "NA", "NA"); # specimen
my($provider_id, $source_name, $source_value) = ("NA", "GEO", "GSE60682"); # source provider (# ideally should be in the input file)
my($assay_occurrence_id, $assay_start_date, $assay_source_value, $assay_type_source_value) = ("NA", "NA", "NA", "NA");
my($assay_occurrence_data_id, $file_source_value) = ("NA", "NA"); # 
my($assay_parameters_id, $reference_source_value, $reference_genome_value) = ("NA", "NA", "NA"); # 
my($condition_occurence_id, $condition_type_value) = ("NA", "NA"); # 
my ($perturbation_id,$perturbation_source_value,$perturbation_type_source_value,$pereturbation_start_date,$perturbation_dose_value_as_number,$perturbation_dose_unit) = ("NA", "NA", "NA", "NA", "NA", "NA");

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
		print PRO_OUT "$array[1],$provider_id,$source_name,$source_value\n"; 

	}

	# join patient_id and condition for creating a unique key
	my $patient_condition = join('_', $array[12],$array[1]);
	## condition_occurence table
	if ((!exists $condition_id{$patient_condition}) and $array[12] =~ /CTCL/) {
		$condition_id{$patient_condition}++;
		$condition_occurence_id = "C$array[1]";
		print C_OUT "$array[1],$condition_occurence_id,$array[12]\n";
	}

	# initialize unique id's for all tables
	$assay_occurrence_id = "A$array[0]";
	$assay_occurrence_data_id = "AD$array[0]";
	$assay_parameters_id = "AP$array[0]";
	$specimen_id = "S$array[0]";

	## specimen table values
	$specimen_source_value = $array[5];
	$specimen_type_source_value = $array[14];
	print S_OUT "$array[1],$specimen_id,$specimen_source_value,$specimen_type_source_value\n";

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

	print A_OUT "$specimen_id,$assay_occurrence_id,$specimen_source_value,$assay_start_date,$assay_source_value,$assay_type_source_value\n";

	## assay_occurrence_data table values
	$file_source_value = $array[17];
	print AD_OUT "$specimen_id,$assay_occurrence_data_id,$file_source_value\n";

	## assay_parameters table values
	$reference_source_value = $array[9];
	$reference_genome_value = $array[18];
	print AP_OUT "$specimen_id,$assay_parameters_id,$reference_source_value,$reference_genome_value\n";

	## perturbation_table
	$perturbation_id = "Z$array[0]";
	$perturbation_source_value = $array[19];
	$perturbation_type_source_value = $array[20];
	$pereturbation_start_date = $array[21];
	$perturbation_dose_value_as_number = $array[22];
	$perturbation_dose_unit  = $array[23];
	print PE_OUT "$specimen_id,$perturbation_id,$perturbation_source_value,$perturbation_type_source_value,$pereturbation_start_date,$perturbation_dose_value_as_number,$perturbation_dose_unit\n";

}