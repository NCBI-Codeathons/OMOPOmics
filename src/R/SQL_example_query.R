setwd("~/Downloads")
library(DBI)
library (tidyverse)
library(dplyr)
library(dbplyr)
library(RSQLite)
#install.packages(c("dbplyr", "RSQLite"))
download.file(url = "https://ndownloader.figshare.com/files/2292171",
              destfile = "data/example_SQL_db/portal_mammals.sqlite", mode = "wb")

# con <- DBI::dbConnect(RSQLite::SQLite(), "data/example_SQL_db/portal_mammals.sqlite")
# dbListTables(con)

# assay_occurrence_data <- tbl(con,"assay_occurrence_data")
# assay_occurrence_parameters <- tbl(con,"assay_occurrence_parameters")
# assay_occurrence <- tbl(con,"assay_occurrence")
# condition_occurrence <- tbl(con,"condition_occurrence")
# person <- tbl(con,"person")
# provider <- tbl(con,"provider")
# specimen <- tbl(con,"specimen")

assay_occurrence_data <- read.csv(file = "OMOP_tables_copy/assay_occurrence_data.txt", header = T, sep = "\t")
assay_occurrence_parameters <- read.csv(file = "OMOP_tables_copy/assay_occurrence_parameters.txt", header = T, sep = "\t")
assay_occurrence <- read.csv(file = "OMOP_tables_copy/assay_occurrence.txt", header = T, sep = "\t")
condition_occurrence <- read.csv(file = "OMOP_tables_copy/condition_occurrence.txt", header = T, sep = "\t")
person <- read.csv(file = "OMOP_tables_copy/person.txt", header = T, sep = "\t")
provider <- read.csv(file = "OMOP_tables_copy/provider.txt", header = T, sep = "\t")
specimen <- read.csv(file = "OMOP_tables_copy/specimen.txt", header = T, sep = "\t")

# # EXAMPLE QUERY 1
# finding male patients...
merge_1_a <- person %>% 
  filter(gender_source_value == "male") %>% 
  inner_join(specimen, by = "person_id") %>% 
  distinct()

# with T-cell activation
merge_1_b <- condition_occurrence %>%
  filter(condition_source_value == "T cell activation") %>% 
  select(person_id,condition_source_value) %>% 
  distinct() %>% 
  inner_join(merge_1_a, by="person_id") %>% 
  distinct()

# with associated ATAC-seq data
merge_1_c <- inner_join(merge_1_b, assay_occurrence %>% filter(assay_source_value == "ATAC"), by="specimen_source_value")

# collect ATAC-seq peak file paths 
merge_1_d <- inner_join(merge_1_c, assay_occurrence_data, by="assay_occurrence_id")
male_TCA_ATAC <- merge_1_d$file_source_value

# export list of filepaths of ATAC-seq data
write.csv(male_TCA_ATAC, file = "data/cohorts/male_TCA_ATAC.csv")

# # EXAMPLE QUERY 2 
# isolates specimen_source_values of everyone that did not fall into query 1 

## NEEDS WORK
anti_join(merge_1_c, assay_occurrence, by="specimen_source_value")

# # EXAMPLE QUERY 3
# finding CTCL patients...
merge_2_a <- condition_occurrence %>%
  filter(condition_source_value == "cutaneous T cell leukemia (CTCL)") %>% 
  inner_join(person, by = "person_id") %>% 
  distinct()

# adding associated specimen_source_value to match against assay_occurance tables
merge_2_b <-specimen %>% 
  inner_join(merge_2_a, by="person_id") %>% 
  distinct()

# selecting patients with ATAC-seq data
merge_2_c <- assay_occurrence %>% 
  filter(assay_source_value == "ATAC") %>% 
  distinct() %>% 
  inner_join(merge_2_a, by="person_id") %>% 
  distinct()

# with associated ATAC-seq data
merge_1_c <- inner_join(merge_1_b, assay_occurrence %>% filter(assay_source_value == "ATAC"), by="specimen_source_value")

# collect ATAC-seq peak file paths 
merge_1_d <- inner_join(merge_1_c, assay_occurrence_data, by="assay_occurrence_id")
male_TCA_ATAC <- merge_1_d$file_source_value

?collect()
show_query(merge1)


dbFetch(res) 


dbDisconnect(con)




