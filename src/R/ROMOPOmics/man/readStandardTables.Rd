% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readStandardTables.R
\name{readStandardTables}
\alias{readStandardTables}
\title{readStandardTables.R}
\usage{
readStandardTables(input_files)
}
\arguments{
\item{standard_table_files}{List of CSV files to incorporate.}
}
\description{
Given a list of standardized table CSV files, function reads each and incorporates
into a single data frame, with each annotated with an "experiment" column
containing the basename of the origin file.
}
