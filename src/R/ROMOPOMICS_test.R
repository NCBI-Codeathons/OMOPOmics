library(ROMOPOmics)
library(magrittr)
library(tidyverse)
library(dbplyr)

in_file   <- "../../data/GSE60682_standard.tsv"

out_dir   <- "../../data"

db  <- dbOMOP(input_files = in_file,
              db_prefix = "omop_tables",
              rebuild = TRUE,
              output_dir = out_dir,
              csv_to_sqlite_location = "~/anaconda3/bin/csv-to-sqlite",
              return_cmd_only = FALSE)

tabs<- getDBTables(db)

  inc_cols  <- c("provider_id","person_id","specimen_id","gender_source_value","gender_concept_id")
  filts     <- list(gender_source_value = "female")

d <- databaseQuery(include_columns = inc_cols,filter_columns = filts)

