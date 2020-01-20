library(shiny)
library(shinyWidgets)
library(dplyr)
library(dbplyr)
library(lubridate)
library(DBI)
library(RSQLite)
library(here)
library(DT)
library(tidyverse)

# setwd to OMOPomics
setwd(here())
here()
base_dir    <- file.path(here(),"src","R","shiny","OMOPOmics")
data_dir    <- file.path(here(),"data")

#Source.
source(file.path(base_dir,"functions.R"))

# connects to SQL database
con         <- DBI::dbConnect(RSQLite::SQLite(), "OMOP_tables.sqlite")

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
