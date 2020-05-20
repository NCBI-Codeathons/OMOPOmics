library(tidyverse)
library(data.table)
library(knitr)
library(kableExtra)
library(here)
library(RSQLite)
library(shiny)
library(DBI)

dirs          <- list()
#dirs$base     <- file.path("/projects/andrew/ROMOPOmics_imp/ROMOPOmics_imp")
dirs$base     <- file.path(here(),"src","R","shiny","ROMOPOmics_demo")
dirs$src      <- file.path(dirs$base,"src")
dirs$data     <- file.path(dirs$base,"data")
dirs$masks    <- file.path(dirs$base,"masks")
dirs$database <- file.path(dirs$data,"database")
dirs$dm_file  <- file.path(dirs$database,"OMOP_CDM_v6_0_custom.csv")
dirs$db_file  <- file.path(dirs$database,"sqlDB.sqlite")

#Source all functions in the src directory.
invisible(lapply(Sys.glob(file.path(dirs$src,"*.R")),source))

#Load data model, and make sure all names are unique.
dm      <- loadDataModel(as_table_list =FALSE,master_table_file=dirs$dm_file)

#Load masks.
msks    <- loadModelMasks(data_model = dm,mask_file_directory = dirs$masks)

#Create separate input directories for each mask.
dirs$inputs       <- as.list(paste(dirs$data,names(msks),sep="/"))
names(dirs$inputs)<- names(msks)
invisible(lapply(dirs$input, function(x) dir.create))

#Append aliases for each mask to data model.
for(i in 1:length(msks)){
  col_nm  <- paste0(names(msks)[i],"_alias")
  dm      <- msks[[i]] %>%
              mutate(table=tolower(table)) %>%
              select(table,field,alias) %>%
              rename(!!as.name(col_nm) := alias) %>%
              merge(dm,.,all.x=TRUE) %>%
              as_tibble()
}

#Read existing data files into comprehensive input tables.
input_files       <- lapply(names(msks), function(x) Sys.glob(paste0(dirs$inputs[[x]],"/*.tsv")))
names(input_files)<- names(msks)
input_tables      <- list()
for(mask in names(msks)){
  fls         <- input_files[[mask]]
  tbs         <- lapply(fls,readInputFiles,data_model=dm,mask_table=msks[[mask]])
  input_tables<- c(input_tables,tbs)
}

#Build DB and SQLite connection. For now these don't change after runtime.
db            <- combineInputTables(input_tables) %>%
                  buildSQLDBR(sql_db_file = dirs$db_file)
db_tabs       <- getDBTables(db,find_key = FALSE)
db_tabs       <- db_tabs[!grepl("^sqlite",names(db_tabs))]

#Key tables.
#For now, always inner_join all tables with at least one table depending on it.
db_key_tabs   <- getDependencies(data_model=dm,inc_tabs = tolower(names(db_tabs))) %>%
                  unlist(use.names=FALSE) %>% unique()

########################################
#Options
opt_dm_select_table     <- c("All",sort(unique(dm$table)))
opt_dm_select_table_def <- "All"
opt_dm_layout           <- c("adj","circle","circrand","eigen",
                             "fruchtermanreingold","geodist","hall","kamadakawai",
                             "mds","princoord","random","rmds","segeo","seham",
                             "spring","springrepulse","target")
opt_dm_layout_def       <- "circle"
opt_msk_layout          <- opt_dm_layout
opt_msk_layout_def      <- "fruchtermanreingold"
opt_mask_select         <- sort(names(msks))
opt_mask_select_def     <- opt_mask_select[2]
opt_db_mask_select      <- c("None",opt_mask_select)
opt_db_mask_select_def  <- "None"
opt_db_field_select     <- getFields(db_tabs,mask = "none")
opt_db_field_select_def <- c("person|person_id","person|gender_source_value","person|hla_source_value","sequencing|file_local_source","sequencing|file_remote_source_url")
opt_db_filt_select      <- opt_db_field_select
opt_db_filt_select_def  <- "person|hla_source_value"

# source(file.path(dirs$base,"scrap.R"))