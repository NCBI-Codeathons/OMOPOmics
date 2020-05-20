#' outputOMOPTables
#'
#' Given a standard table that has been processed to include IDs for all OMOP
#' tables and an output directory, function summarizes and sorts each into an
#' output CSV file which it places in the output directory. These CSVs are the
#' inputs for creating the SQLite database.
#'
#' @param standard_table Input standard table with each OMOP table's respective index column added.
#' @param omop_table_directory Directory into which OMOP tables will be placed.
#'
#' @import tidyverse
#' @import stringr
#'
#' outputOMOPTables()
#'
#' @export

outputOMOPTables  <- function(standard_table,omop_table_directory){
  omop_tables     <- blankOMOPTables()
  tabs  <- lapply(names(omop_tables), function(x){
            col_inc <- colnames(omop_tables[[x]])
            out_fl  <- file.path(omop_table_directory,paste0(x,".csv"))
            standard_table %>%
              select_at(col_inc) %>%
              group_by_at(1) %>%
              summarize_all(function(x) first(x)) %>%
              ungroup() %>%
              arrange_at(1,function(x) as.numeric(stringr::str_extract(x,"[:digit:]+"))) %>%
              write.table(file = out_fl,sep = ",",row.names = FALSE,col.names = TRUE,quote=FALSE)
            return(out_fl)})
  names(tabs)   <- names(omop_tables)
  return(tabs)
}
