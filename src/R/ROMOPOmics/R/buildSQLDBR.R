#' buildSQLDBR.R
#'
#' Function uses dplyr's src_sqlite() function to create the SQLite database.
#' While functional, this process requires reading in all input standard csvs,
#' which makes this a poor choice for scaling upwards. If available, use
#' buildSQLDB() instead.
#'
#' @param omop_csvs Filesnames of all OMOP csv files to be incorporated into the database.
#' @param sql_db_file Filename under which to store the SQLite database file.
#'
#' @import tidyverse
#'
#' buildSQLDBR()
#'
#' @export

buildSQLDBR       <- function(omop_csvs,sql_db_file = file.path(dirs$data,"OMOP_tables.sqlite")){
  #Accepts a list of named CSV tables and returns a dabase with each incorporated.
  #BUT: slow if database CSVs get large, so maybe use csv-to-sqlite after all.
  #https://datacarpentry.org/R-ecology-lesson/05-r-and-databases.html#creating_a_new_sqlite_database
  db            <- src_sqlite(sql_db_file,create=TRUE)
  lapply(names(omop_csvs),function(x) copy_to(db,omop_csvs[[x]],name=x,overwrite = TRUE))
  return(db)
}
