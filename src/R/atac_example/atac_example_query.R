
suppressMessages(library(tidyverse))
suppressMessages(library(dbplyr))
suppressMessages(library(lubridate))
suppressMessages(library(DBI))
suppressMessages(library(RSQLite))
suppressMessages(library(DT))
suppressMessages(library(here))

# setwd to OMOPomics
here        <- here::here
setwd(here())
base_dir    <- file.path(here(),"src","R","shiny","OMOPOmics")
data_dir    <- file.path(here(),"data")
tabs_dir    <- file.path(data_dir,"OMOP_tables")

#Source.
source(file.path(base_dir,"functions.R"))
select      <- dplyr::select
mutate      <- dplyr::mutate
arrange     <- dplyr::arrange

# connects to SQL database
con         <- DBI::dbConnect(RSQLite::SQLite(), "OMOP_tables_new.sqlite")

# lists tables in database, load into R.
tab_names   <- dbListTables(con)
tab_names   <- tab_names[!tab_names == "condition_occurence"]
tabs        <- lapply(tab_names, function(x) tbl(con,x))
names(tabs) <- tab_names

#Perform search, write table.
suppressMessages(
  tabs$specimen_table %>%
    inner_join(tabs$perturbation) %>%
    inner_join(tabs$assay_occurrence_data) %>%
    filter(perturbation_source_value %in% c("placebo","ionomycin") & 
           perturbation_start_date %in% c("0:00:00","1:00:00","2:00:00","4:00:00"),
           perturbation_dose_unit == "ug/mL") %>% 
    select(file_source_value,perturbation_source_value,perturbation_start_date) %>%
    write.table(sep=",",quote = FALSE,row.names = FALSE)
)
