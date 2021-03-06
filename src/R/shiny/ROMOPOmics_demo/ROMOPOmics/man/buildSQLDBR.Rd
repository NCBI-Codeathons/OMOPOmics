% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/buildSQLDBR.R
\name{buildSQLDBR}
\alias{buildSQLDBR}
\title{buildSQLDBR.R}
\usage{
buildSQLDBR(
  omop_tables,
  sql_db_file = file.path(dirs$data, "OMOP_tables.sqlite")
)
}
\arguments{
\item{omop_tables}{Filesnames of all OMOP csv files to be incorporated into the database.}

\item{sql_db_file}{Filename under which to store the SQLite database file.}
}
\description{
Function uses dplyr's src_sqlite() function to create the SQLite database.
While functional, this process requires reading in all input standard csvs,
which makes this a poor choice for scaling upwards. If available, use
buildSQLDB() instead.
}
