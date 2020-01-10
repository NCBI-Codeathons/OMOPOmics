DROP TABLE ASSAYPARS;
DROP TABLE ASSAYDATA;
DROP TABLE ASSAYOCCURENCE;
DROP TABLE SPECIMEN;
DROP TABLE CONDOCCURENCE;
DROP TABLE PROVIDER;
DROP TABLE PERSON;

CREATE TABLE PERSON(
Person_id VARCHAR(150) PRIMARY KEY,
gender_concept_id VARCHAR(150),
person_sourceval VARCHAR(150),
gender_sourceval VARCHAR(150)); 

CREATE TABLE PROVIDER(
Person_id VARCHAR(150),
provider_id VARCHAR(150) PRIMARY KEY,
provider_sourceval VARCHAR(150),
provider_type_sourceval VARCHAR(150),
FOREIGN KEY (Person_id) REFERENCES PERSON(Person_id) ON DELETE SET NULL);  

CREATE TABLE CONDOCCURENCE(
Person_id VARCHAR(150),
cond_occ_id VARCHAR(150) PRIMARY KEY,
condition_startdate VARCHAR(150),
FOREIGN KEY (Person_id) REFERENCES PERSON(Person_id) ON DELETE SET NULL);

CREATE TABLE SPECIMEN(
Person_id VARCHAR(150),
Specimen_id VARCHAR(150) PRIMARY KEY,
specimen_sourceval VARCHAR(150) ,
specimen_type_sourceval VARCHAR(150),
FOREIGN KEY (Person_id) REFERENCES PERSON(Person_id) ON DELETE SET NULL);

CREATE TABLE ASSAYOCCURENCE(
Specimen_id VARCHAR(150),
assay_occurence_id VARCHAR(150) PRIMARY KEY,
specimen_sourceval VARCHAR(150),
assay_startdate VARCHAR(150),
assay_sourceval VARCHAR(150),
assay_type_sourceval VARCHAR(150),
FOREIGN KEY (Specimen_id) REFERENCES SPECIMEN(Specimen_id) ON DELETE SET NULL);

CREATE TABLE ASSAYDATA(
Specimen_id VARCHAR(150),
assay_occurence_id VARCHAR(150) PRIMARY KEY,
file_source_val VARCHAR(300),
FOREIGN KEY (Specimen_id) REFERENCES SPECIMEN(Specimen_id) ON DELETE SET NULL);

CREATE TABLE ASSAYPARS(
Specimen_id VARCHAR(150),
assay_parameters_id VARCHAR(150) PRIMARY KEY,
reference_source_val VARCHAR(150),
reference_genome_val VARCHAR(300) ,
FOREIGN KEY (Specimen_id) REFERENCES SPECIMEN(Specimen_id) ON DELETE SET NULL);

LOAD DATA LOCAL INFILE 'OMOP_tables\person_table.csv'
  INTO TABLE PERSON
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from person;
 
 LOAD DATA LOCAL INFILE 'OMOP_tables\provider_table.csv'
  INTO TABLE PROVIDER
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from PROVIDER;
 
 LOAD DATA LOCAL INFILE 'OMOP_tables\condition_occurence.csv'
  INTO TABLE CONDOCCURENCE
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from CONDOCCURENCE;

 LOAD DATA LOCAL INFILE 'OMOP_tables\specimen_table.csv'
  INTO TABLE SPECIMEN
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from SPECIMEN;
 
  LOAD DATA LOCAL INFILE 'OMOP_tables\assay_occurrence.csv'
  INTO TABLE ASSAYOCCURENCE
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from ASSAYOCCURENCE;
 
  LOAD DATA LOCAL INFILE 'OMOP_tables\assay_occurrence_data.csv'
  INTO TABLE ASSAYDATA
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from ASSAYDATA;
 
  LOAD DATA LOCAL INFILE 'OMOP_tables\assay_parameters.csv'
  INTO TABLE ASSAYPARS
  FIELDS TERMINATED BY ','
  IGNORE 1 LINES;
  
 Select * from ASSAYPARS;
 
 