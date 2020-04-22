#!/bin/Rscript
#databaseQuery
# Given a vector of columns to include and a list of named filters to apply,
# function uses queryTrace() to identify required tables and inner_joins them
# recursively to produce a query, then applies filters using stackedFilters().
# Finally, function selects() columns to be included and returns the query.

databaseQuery <- function(table_list=tabs){
  Reduce(inner_join,table_list) %>%
    return()
}
#qu  <- databaseQuery(inc_cols = opt_include_cols_def,filter_columns = c("gender_source_id","specimen_id"))
