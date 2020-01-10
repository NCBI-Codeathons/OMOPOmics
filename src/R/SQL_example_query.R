# setwd to OMOPomics
setwd("")
 

# connects to SQL database
con <- DBI::dbConnect(RSQLite::SQLite(), "OMOP_tables.sqlite")
# lists tables in database
dbListTables(con)

# loads database tables into R
assay_occurrence_data <- tbl(con,"assay_occurrence_data")
assay_occurrence <- tbl(con,"assay_occurrence")
condition_occurrence <- tbl(con,"condition_occurrence")
person <- tbl(con,"person_table")
provider <- tbl(con,"provider_table")
specimen <- tbl(con,"specimen_table")
perturbation <- tbl(con,"perturbation")

# if you wish to add parameters for sequencing details, do so in the assay occurence table
# assay_occurrence_parameters <- tbl(con,"assay_occurrence_parameters")

# # EXAMPLE QUERY 1 ALL FEMALE PATIENTS W/ ATAC-seq
# merge sample and person data
merge_1_a <- person %>% 
  inner_join(specimen, by = "person_id") %>% 
  distinct()

# female patients only 
merge_1_b <- filter(merge_0_a, gender_source_value == "female") %>% 
  distinct()

# with associated ATAC-seq data
merge_1_c <- inner_join(merge_1_b, assay_occurrence %>% filter(assay_source_value == "ATAC"), by="specimen_id", copy = T) %>% 
  distinct()

?inner_join()
# collect ATAC-seq peak file paths 
merge_1_d <- inner_join(merge_1_c, assay_occurrence_data, by="specimen_id", copy = T)
merge_1_d_comp <- compute(merge_1_d)
merge_1_d_coll <- collect(merge_1_d_comp)
all_female_ATAC <- merge_1_d_coll$file_source_value

# export list of filepaths of ATAC-seq data
write.csv(all_CTCL_ATAC, file = "data/cohorts/all_female_ATAC.csv")

#_______________________________________________________________

# # EXAMPLE QUERY 2 ALL CTCL PATIENTS W/ ATAC SEQ
# merge sample and person data
merge_2_a <- person %>% 
  inner_join(specimen, by = "person_id") %>% 
  distinct()

# finding CTCL patients...
merge_2_b <- condition_occurrence %>%
  filter(condition_type_value == "cutaneous T cell leukemia (CTCL)") %>% 
  inner_join(merge_2_a, by = "person_id", copy = T) %>% 
  distinct()

# selecting patients with ATAC-seq data
merge_2_c <- assay_occurrence %>% 
  filter(assay_source_value == "ATAC") %>% 
  distinct() %>% 
  inner_join(merge_2_b, by="specimen_id", copy = T) %>% 
  distinct()

# collect ATAC-seq peak file paths 
merge_2_d <- inner_join(merge_2_c, assay_occurrence_data, by="specimen_id")
merge_2_d_comp <- compute(merge_2_d)
merge_2_d_coll <- collect(merge_2_d_comp)
all_CTCL_ATAC <- merge_2_d_coll$file_source_value

# export list of filepaths of ATAC-seq data
write.csv(all_CTCL_ATAC, file = "data/cohorts/all_CTCL_ATAC.csv")

#_______________________________________________________________

# # EXAMPLE QUERY 4 ALL SAMPLES WITH A RAPID T-Cell ACTIVATION TIMECOURSE
# merge sample and person data
merge_3_a <- person %>% 
  inner_join(specimen, by = "person_id") %>% 
  distinct()

specimen
# finding T-cell activation samples
merge_3_b <- perturbation %>%
  filter(perturbation_type_source_value == "activation") %>% 
  inner_join(merge_3_a, copy = T) %>% 
  distinct()

# selecting patients with ATAC-seq data
merge_3_c <- assay_occurrence %>% 
  filter(assay_source_value == "ATAC") %>% 
  distinct() %>% 
  inner_join(merge_3_b, by="specimen_id", copy = T) %>% 
  distinct()

# collect ATAC-seq peak file paths 
merge_3_d <- inner_join(merge_3_c, assay_occurrence_data, by="specimen_id")
merge_3_d_comp <- compute(merge_3_d)
merge_3_d_coll <- collect(merge_3_d_comp)
TimeCourse <- merge_3_d_coll$file_source_value

# export list of filepaths of ATAC-seq data
write.csv(all_CTCL_ATAC, file = "data/cohorts/all_CTCL_ATAC.csv")







# with T-cell activation
merge_4_b <- condition_occurrence %>%
  filter(condition_type_value == "T cell activation") %>% 
  select(person_id,condition_type_value) %>% 
  distinct() %>% 
  inner_join(merge_4_a, by="person_id") %>% 
  distinct()

# selecting patients with ATAC-seq data and timecourse data within 4 hour window
merge_4_c <- assay_occurrence %>% 
  filter(as.numeric(hms(assay_start_date)) <= 14400) %>% 
  distinct() %>% 
  inner_join(merge_4_b, by="specimen_source_value") %>% 
  distinct()

# collect ATAC-seq peak file paths 
merge_4_d <- inner_join(merge_4_c, assay_occurrence_data, by="assay_occurrence_id")
all_Timecourse <- merge_4_c$file_source_value

# export list of filepaths of ATAC-seq data
write.csv(all_CTCL_ATAC, file = "data/cohorts/all_Timecourse.csv")


show_query(merge1)


dbFetch(res) 


dbDisconnect(con)


# assay_occurrence_data <- read.csv(file = "OMOP_tables_copy/assay_occurrence_data.txt", header = T, sep = "\t")
# assay_occurrence_parameters <- read.csv(file = "OMOP_tables_copy/assay_occurrence_parameters.txt", header = T, sep = "\t")
# assay_occurrence <- read.csv(file = "OMOP_tables_copy/assay_occurrence.txt", header = T, sep = "\t")
# condition_occurrence <- read.csv(file = "OMOP_tables_copy/condition_occurrence.txt", header = T, sep = "\t")
# person <- read.csv(file = "OMOP_tables_copy/person.txt", header = T, sep = "\t")
# provider <- read.csv(file = "OMOP_tables_copy/provider.txt", header = T, sep = "\t")
# specimen <- read.csv(file = "OMOP_tables_copy/specimen.txt", header = T, sep = "\t")


# with CTCL
merge_0_c <- condition_occurrence %>%
  filter(condition_type_value == "cutaneous T cell leukemia (CTCL)") %>% 
  select(person_id, condition_type_value) %>%
  distinct() %>%
  inner_join(merge_0_b, by="person_id") %>% 
  distinct()

# finding male patients...
merge_1_a <- person %>% 
  filter(gender_source_value == "male") %>% 
  inner_join(specimen, by = "person_id") %>% 
  distinct()

# with T-cell activation
merge_1_b <- condition_occurrence %>%
  filter(condition_type_value == "T cell activation") %>% 
  select(person_id,condition_type_value) %>% 
  distinct() %>% 
  inner_join(merge_1_a, by="person_id") %>% 
  distinct()



# export list of filepaths of ATAC-seq data
write.csv(male_TCA_ATAC, file = "data/cohorts/male_TCA_ATAC.csv")



