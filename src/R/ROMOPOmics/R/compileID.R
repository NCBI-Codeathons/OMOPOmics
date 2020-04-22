#' compileID
#'
#' Given an input standard table and the names of each column to be included in
#' an OMOP table, function adds a column named <id_column> with a unique ID for
#' each permutation of the other included columns. Columns not found in the
#' table are ignored without a warning.
#'
#' @param table_input Standard table being processed.
#' @param id_column String with the intended name of the new ID column.
#' @param id_pfx If a prefix is to be appended to the ID, include it here.
#' @param inc_columns Names of existing columns in the table to be included.
#'
#' @import tidyverse
#'
#' compileID()
#'
#' @export

compileID         <- function(table_input,id_column,id_pfx,inc_columns){
  mutate    <- dplyr::mutate
  in_cols   <- inc_columns[inc_columns %in% colnames(table_input)] #Shorthand ignores non-existent columns (such as yet-non-existent ids).
  if(missing(id_pfx)){id_pfx <- NULL}
  table_input %>%
    group_by_at(in_cols) %>%
    mutate(!!as.name(id_column):= paste0(id_pfx,group_indices())) %>%
    ungroup() %>%
    return()
}
