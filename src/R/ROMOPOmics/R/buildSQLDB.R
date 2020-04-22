#' buildSQLDBR.R
#'
#' Function uses the python csv-to-sqlite function to create a SQLite database.
#' Requires that csv-to-sqlite is in the path, or provided via the
#' <csv_to_sqlite_loc> argument. Returns the filename of the database created.
#'
#' @param omop_csvs Filesnames of all OMOP csv files to be incorporated into the database.
#' @param sql_db_file Filename under which to store the SQLite database file.
#' @param csv_to_sqlite_loc Location of csv-to-sqlite executable. If not provided, function attempts to use executable in the path.
#' @param return_cmd_only For debugging purposes; if TRUE, returns only the command to be executed and does not execute it.
#'
#' buildSQLDB()
#'
#' @export

buildSQLDB        <- function(omop_csvs,sql_db_file,csv_to_sqlite_loc=NULL,return_cmd_only=FALSE){
  if(is.null(csv_to_sqlite_loc)){
    cmd   <- paste("csv-to-sqlite -f",paste(omop_csvs,collapse = " -f "),"-o",sql_db_file,"-D")
  }else{
    cmd   <- paste(csv_to_sqlite_loc,"-f",paste(omop_csvs,collapse = " -f "),"-o",sql_db_file,"-D")
  }
  if(return_cmd_only){
    return(cmd)
  }else{
    system(cmd)
    return(sql_db_file)
  }
}
