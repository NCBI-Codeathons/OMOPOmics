#' dbOMOP.R
#'
#' Wrapper function that should encapsulate most of the behavior of ROMOPOmics.
#' Given a list of standard tables and a destination database name, function
#' first checks if that database file exists (filename.sqlite). If so, and if
#' rebuild is not set to TRUE, function returns a connection to the existing
#' database, with a warning if rebuild is missing. If the database file isn't
#' found or rebuild == TRUE, function combines each input CSV file into a
#' comprehensive table with readStandardTables(), adds all required indices
#' based on OMOP tables in the definition file, writes these tables with
#' indices to CSVs in the <omop_tables> directory with outputOMOPTables(), and
#' finally builds the database with buildSQLDB(). In either case, the new/
#' existing database file is read into memory using DBI::dbConnect() and
#' RSQLite::SQLite().
#'
#' @param input_files Filenames for standard input CSV files.
#' @param db_file Filename of the resulting database, which will be placed in the output directory.
#' @param rebuild If TRUE, existing database files are overwritten.
#' @param output_dir Directory in which output files, including OMOP tables and the database file, will be placed.
#' @param csv_to_sqlite_location csv-to-sqlite executable location, if path is to be bypassed.
#' @param omop_definitions_csv Alternate CSV file with standard input column names and their respective OMOP equivalents. If not provided, package default is used from extdata.
#' @param return_cmd_only For debugging purposes; if TRUE, the csv-to-sqlite command executed by buildSQLDB() is returned rather than a database connection.
#'
#' @import DBI
#' @import RSQLite
#' @import dplyr
#' @import data.table
#'
#' dbOMOP()
#'
#' @export

dbOMOP          <- function(input_files,db_prefix = "OMOP_db",rebuild=FALSE,output_dir=NULL,csv_to_sqlite_location=NULL,omop_definitions_csv=NULL,return_cmd_only=FALSE){
  if(is.null(output_dir)){
    output_dir  <- "."
  }
  if(!dir.exists(output_dir)){
    stop("Output directory [",output_dir,"] does not exist, create it first.")
  }
  omop_table_dir<- file.path(output_dir,"omop_tables")
  db_file       <- file.path(output_dir,paste0(db_prefix,".sqlite"))
  if(file.exists(db_file) & !rebuild){
    message("Using existing OMOP database file '",basename(db_file),".' To rebuild and overwrite, set 'rebuild=TRUE'")
  }else{
    message("Building OMOP database '",db_file,
            "'\nIncorporating ",length(input_files),
            " standard file",ifelse(length(input_files)>1,"s",""),
            ":\n",paste(basename(input_files),collapse="\n\t"))
    dir.create(omop_table_dir,showWarnings = FALSE)
    outpt   <- input_files %>%
                readStandardTables() %>%
                parseToOMOP() %>%
                outputOMOPTables(omop_table_directory = omop_table_dir) %>%
                buildSQLDB(sql_db_file = db_file,
                           csv_to_sqlite_loc = csv_to_sqlite_location,
                           return_cmd_only = return_cmd_only)
  }
  if(return_cmd_only){
    return(outpt)
  }else{
    db  <- DBI::dbConnect(RSQLite::SQLite(),db_file)
    return(db)
  }
}
