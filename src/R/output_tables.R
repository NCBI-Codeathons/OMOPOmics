#!/bin/Rscript
library(tidyverse)
library(data.table)
library(dbplyr)
library(lubridate)
library(here)
library(DBI)
library(RSQLite)

#################
#   Functions   #
#################
getDirs           <- function(base_dir=here()){
  dirs            <- list(base=base_dir)
  dirs$data       <- file.path(dirs$base,"data")
  dirs$standards  <- file.path(dirs$data,"standard_tables")
  dirs$omop_tables<- file.path(dirs$data,"omop_tables")
  dirs$raw        <- file.path(dirs$data,"raw")
  return(dirs)
}
genderConceptID   <- function(gender_val="Male"){
  #Convert assorted sex values to their respective IDs.
  sapply(tolower(as.character(gender_val)), function(x) 
    case_when(x=="male" ~ "8507",
              x=="m" ~ "8507",
              x=="8507" ~ "8507",
              x=="female" ~ "8532",
              x=="f" ~ "8532",
              x=="8532" ~ "8532",
              TRUE ~ "8551"))
}
compileID         <- function(table_input,id_column = "person_id",id_pfx = NULL,inc_columns = c("person_id","gender_concept_id","person_source_value","gender_source_value")){
  #Given all columns to include in a table, assign an ID to each unique permutation.
  in_cols   <- inc_columns[inc_columns %in% colnames(table_input)] #Shorthand ignores non-existent columns (such as yet-non-existent ids).
  table_input %>%
    group_by_at(in_cols) %>%
    mutate(!!as.name(id_column):= paste0(id_pfx,group_indices())) %>%
    ungroup() %>%
    return()
}
blankOMOPTables   <- function(table_definitions=file.path(dirs$data,"omop_cdm_tables.csv"),table_names = NULL){
  #Given a standardized table of OMOP terms, classes, and definitions, returns an empty table of each.
  #If "table_names" provided, only return tables with these names.
  om_tib  <- as_tibble(fread(table_definitions,header=TRUE,sep=",")) %>%
              arrange(table)
  tibs    <- om_tib %>%
              group_split(table) %>%
              lapply( function(x) {
                mtx   <- matrix(nrow=0,ncol=nrow(x))
                colnames(mtx)   <- unlist(select(x,name))
                tib   <- as_tibble(mtx)
                col_classes     <- unlist(select(x,class))
                for(i in 1:length(col_classes)){
                  class(tib[,i])<- col_classes[i]
                }
                return(tib)
              })
  names(tibs)   <- unique(om_tib$table)
  if(is.null(table_names)){
    return(tibs)
  }
  present_tables  <- sapply(table_names, function(x) x %in% names(tibs))
  if(any(!present_tables)){
    message(
      paste0("\nTable(s) not found:\n",
        paste(names(present_tables)[!present_tables],collapse=", "),".\n"))
  }
  if(any(present_tables)){
    return(tibs[names(which(present_tables))])
  }
}
readStandardTables<- function(standard_table_files){
  #Given a list of compliant standard file inputs, generate a complete table and use the basename to annotate each with an "experiment" column.
  st_fls        <- standard_table_files
  names(st_fls) <- gsub("\\.tsv","",basename(st_fls))
  lapply(names(st_fls), function(x) 
    fread(st_fls[[x]],header = TRUE) %>%
      as_tibble() %>%
      mutate(experiment=x)) %>%
  do.call(rbind,.) %>%
  return()
}
parseToOMOPFormat <- function(standard_table,omop_tables=blankOMOPTables()){
  #Given a compiled standard file, rename each required column to OMOP equivalent.
  # Then, append unique IDs for each OMOP table based on available permutations
  # among their consituent columns using compileID().
  # Doing this in order of dependent tables and in a separate function from the
  # table output functions ensures that all dependent columns are included.
  standard_table %>%
    mutate(gender_concept_id=genderConceptID(sex)) %>%
    rename(specimen_source_value = sample_name,
           specimen_type_source_value = cell_type,
           person_source_value = patient_name,
           person_id = patient,
           gender_source_value = sex,
           provider_source_value = source,
           provider_type_source_value = source_id,
           reference_source_value = organism,
           reference_genome_value = reference_genome,
           assay_start_date = time_point,
           assay_source_value = assay,
           assay_type_source_value = assay_type,
           file_source_value = local_file_name,
           condition_type_value = disease) %>%
    compileID("specimen_id",id_pfx = "S",inc_columns=colnames(omop_tables$specimen)) %>%
    compileID("provider_id",id_pfx = "P",inc_columns=colnames(omop_tables$provider)) %>%
    compileID("assay_parameters_id",id_pfx="AP",inc_columns=colnames(omop_tables$assay_parameters)) %>%
    compileID("assay_occurrence_id",id_pfx = "A",inc_columns = colnames(omop_tables$assay_occurrence)) %>%
    compileID("assay_occurrence_data_id",id_pfx="AD",inc_columns = colnames(omop_tables$assay_occurrence_data)) %>%
    compileID("condition_occurrence_id",id_pfx ="C",inc_columns = colnames(omop_tables$condition_occurrence)) %>%
    compileID("perturbation_id",id_pfx = "Z",inc_columns = colnames(omop_tables$perturbation)) %>%
    #select(ends_with("id"),everything()) %>%
    return()
}
outputOMOPTables  <- function(standard_table,omop_tables=blankOMOPTables(),omop_table_directory = dirs$omop_tables){
  #Given an indexed standard table and a list of (presumably blank) OMOP tables
  # this function condenses each table's consitutive columns into one row per
  # ID, sorts them by ID, and saves to a <table_name>.tsv file in the OMOP
  # table directory. Overwrites existing tables.
  tabs  <- lapply(names(omop_tables), function(x){
            col_inc <- colnames(omop_tables[[x]])
            out_fl  <- file.path(omop_table_directory,paste0(x,".csv"))
            standard_table %>%
              select_at(col_inc) %>%
              group_by_at(1) %>%
              summarize_all(function(x) first(x)) %>%
              ungroup() %>%
              arrange_at(1,function(x) as.numeric(str_extract(x,"[:digit:]+"))) %>%
            write.table(file = out_fl,sep = ",",row.names = FALSE,col.names = TRUE,quote=FALSE)
            return(out_fl)})
  names(tabs)   <- names(omop_tables)
  return(tabs)
}
buildSQLDBR       <- function(omop_csvs,sql_db_file = file.path(dirs$data,"OMOP_tables.sqlite")){
  #Accepts a list of named CSV tables and returns a dabase with each incorporated.
  #BUT: slow if database CSVs get large, so maybe use csv-to-sqlite after all.
  #https://datacarpentry.org/R-ecology-lesson/05-r-and-databases.html#creating_a_new_sqlite_database
  db            <- src_sqlite(sql_db_file,create=TRUE)
  #for(i in 1:length(omop_csvs)){
   # copy_to(db,omop_csvs[[i]],name=names(omop_csvs)[i],overwrite=TRUE)
  #}
  lapply(names(omop_csvs),function(x) copy_to(db,omop_csvs[[x]],name=x,overwrite = TRUE))
  return(db)
}
buildSQLDB        <- function(omop_csvs,sql_db_file = file.path(dirs$data,"OMOP_tables.sqlite"),csv_to_sqlite_loc="~/anaconda3/bin/csv-to-sqlite"){
  if(is.null(csv_to_sqlite_loc)){
    cmd   <- paste("csv-to-sqlite -f",paste(omop_csvs,collapse = " -f "),"-o",sql_db_file,"-D")
  }else{
    cmd   <- paste(csv_to_sqlite_loc,"-f",paste(omop_csvs,collapse = " -f "),"-o",sql_db_file,"-D")
  }
  return(sql_db_file)
}
dbOMOP            <- function(db_file = "OMOP_tables.sqlite",rebuild,csv_to_sqlite_location=NULL,base_dir=here::here()){
  #Wrapper function for producing a SQLite database based on all input 
  # "standard" files in standard directory. If database is already found and
  # "rebuild" is not set to TRUE, returns the database connection to the
  # existing file. If rebuild is TRUE, incorporates all CSV files in the 
  # standard directory and builds into a database.
  dirs          <- getDirs(base_dir)
  db_file       <- file.path(dirs$data,db_file)
  if(file.exists(db_file)){
    if(missing(rebuild)){
      message("Using existing OMOP database file '",basename(db_file),".'. To rebuild and overwrite, set 'rebuild=FALSE'")
    }
  }else{
    fls         <- Sys.glob(paste0(dirs$standards,"/*.tsv"))  #Check data directory for all "*_standard.tsv" files.
    message("Incorporating ",length(fls)," standard file",ifelse(length(fls)>1,"s",""),":\n",dirs$standards,"/\n\t",paste(basename(fls),collapse="\n\t"))
    fls %>%
      readStandardTables() %>%
      parseToOMOPFormat(omop_tables = blankOMOPTables()) %>%
      outputOMOPTables(omop_tables = blankOMOPTables(),omop_table_directory = dirs$omop_tables) %>%
      buildSQLDB(sql_db_file = db_file,csv_to_sqlite_loc = csv_to_sqlite_location)    
  }
  db  <- DBI::dbConnect(RSQLite::SQLite(),db_file)
  return(db)
}

############
#   Main    #
#############
#Include table descriptions and standard format in package.
#https://kbroman.org/pkg_primer/pages/data.html
db  <- dbOMOP(rebuild=TRUE)

