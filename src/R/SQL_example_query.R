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
merge1 <- person %>% filter(gender_source_value == "male") %>% inner_join(specimen, by = "person_id")

# with T-cell activation
merge2 <- inner_join(merge1, condition_occurrence %>% filter(condition_source_value == "T cell activation"), by="person_id")

# with associated ATAC-seq data
merge3 <- inner_join(merge2, assay_occurrence %>% filter(assay_source_value == "ATAC"), by="specimen_source_value")

# collect ATAC-seq peak file paths 
merge4 <- inner_join(merge3, assay_occurrence_data, by="assay_occurrence_id")

male_TCA_ATAC <- merge4$file_source_value

# export list of filepaths of ATAC-seq data
write.csv(male_TCA_ATAC, file = "data/cohorts/male_TCA_ATAC.csv")



?collect()
show_query(merge1)


dbFetch(res) 


dbDisconnect(con)




