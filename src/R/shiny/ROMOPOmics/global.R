library(ROMOPOmics)
library(shiny)
library(shinydust)
library(shinyWidgets)
library(dplyr)
library(dbplyr)
library(lubridate)
library(DBI)
library(RSQLite)
library(DT)
library(reshape2)
library(tidyverse)
library(here)

here    <- here::here
base_dir<- file.path(here(),"src","R","shiny","ROMOPOmics")
data_dir<- file.path(here(),"data")
src_dir <- file.path(base_dir,"src")
select  <- dplyr::select
mutate  <- dplyr::mutate
arrange <- dplyr::arrange

#Source.
lapply(Sys.glob(file.path(src_dir,"*.R")),source)

#Connect to / create SQL database.
con     <- dbOMOP(input_files = file.path(data_dir,"GSE60682_standard.tsv"),
                  db_prefix = "OMOP_tables",
                  rebuild = TRUE,
                  output_dir = data_dir,
                  csv_to_sqlite_location = "~/anaconda3/bin/csv-to-sqlite")
#Get all tables in the current database.
tabs    <- getDBTables(con)

#Get "key tables," for now any table with a dependency.
key_tabs<- getKeyTables(tabs)
# Including these in any given query guarantees a path exists between tables.
# Change this by changing the getKeyTables.R script.
# Current iteration: keep all tables with any dependent tables (specimen and person).

plotTableNetwork(tabs,inc_tables = key_tabs)







#Options.
opt_tables          <- c("All",sort(names(tabs)))
opt_include_cols    <- tabQueryTable()$omop_name
opt_include_cols_def<- c("person_id",
                         "specimen_id",
                         "gender_source_value",
                         "file_source_value")
opt_filter_logic    <- c("is","is not","contains","does not contain")
opt_filter_logic_def<- "is"
#opt_filter_direc    <- c("include","exclude")
#opt_filter_direc_def<- "include"

#filt_cols <- list(gender_source_value = "female")
all_flt_cols      <- all_inc_cols
default_flt_cols  <- c()
