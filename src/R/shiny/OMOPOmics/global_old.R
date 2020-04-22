library(shiny)
library(shinyWidgets)
library(ROMOPOmics)
library(dplyr)
library(dbplyr)
library(lubridate)
library(DBI)
library(RSQLite)
library(DT)
library(tidyverse)
library(here)

base_dir    <- file.path(here(),"src","R","shiny","OMOPOmics")
data_dir    <- file.path(here(),"data")
tabs_dir    <- file.path(data_dir,"OMOP_tables")

#Source.
source(file.path(base_dir,"functions.R"))
select  <- dplyr::select
mutate  <- dplyr::mutate
arrange <- dplyr::arrange

# Build and/or connect to SQLite database.
db_filename <- "OMOP_tables"
con         <- dbOMOP(input_files = file.path(data_dir,"GSE60682_standard.tsv"))
con         <- DBI::dbConnect(RSQLite::SQLite(), "OMOP_tables_new.sqlite")
if(file.size(db_filename)==0){
  #For use with updated 'GSE60682_details.tsv'. If db file is empty, create a
  # new database using tables in the OMOP_tables directory.
  db_tab_files        <- Sys.glob(file.path(tabs_dir,"*.csv"))
  names(db_tab_files) <- gsub(".csv","",basename(db_tab_files))
  tabs                <- lapply(db_tab_files,function(x) read.table(x,header = TRUE,sep = ",",stringsAsFactors = FALSE))
  lapply(names(tabs), function(x) dbCreateTable(conn = con,name = x,fields = tabs[[x]]))
  lapply(names(tabs), function(x) dbAppendTable(conn = con,name = x,value = tabs[[x]]))
}

# lists tables in database, load into R.
tab_names   <- dbListTables(con)
tab_names   <- tab_names[!tab_names == "condition_occurence"] #Remove misspelled "condition_occurence.csv" name.
tabs        <- lapply(tab_names, function(x) tbl(con,x))
names(tabs) <- tab_names
#Key table: table that must always be inner_joined to ensure a path between tabs.
key_table   <- "specimen_table" #Is this valid? Should we be able to take any
                                #combination of tables? If so we need a way to
                                #trace a path through inner_joins.
#Bump key_table to front of line.
tabs        <- c(tabs[names(tabs)==key_table],tabs[names(tabs) != key_table])

#Default selections: column names that are automatically selected (UI toggle
# set to TRUE).
# Ad-hoc approach; a better UI should be made later, but for now include file
# names at a minimum.
def_cols    <- c("file_source_value")
