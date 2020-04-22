#' getTableDependencies
#'
#' Given a list of tables from an SQLite DB object, function identifies each
#' table's dependencies. 'Dependency' here is defined as requiring an index
#' column from another table. For instance, Table A depends on Table B if it
#' includes Table B's index column. I.e., Table A cannot be queried without
#' Table B. For the most part, this is useful for identifying at least one
#' independent table whose inclusion should guarantee that all queries are
#' possible, though results could be useful elsewhere.
#'
#' Function assumes that all table IDs are in the "<table_name>_id" format.
#'
#' @param table_list Named list of tables pulled from an existing SQLite DB object.
#'
#' getTableDependencies()
#'
#' @import tibble
#' @import data.table
#'
#' @export

getTableDependencies  <- function(table_list){
  id_cols     <- paste(names(table_list),"id",sep="_") #One ID col. per table.
  deps        <- lapply(names(table_list),function(x) {
                  tab <- table_list[[x]]
                  ids <- id_cols[id_cols %in% colnames(tab)] %>% gsub("_id","",.)
                  ids <- ids[ids != x]
                  return(ids)})
  names(deps) <- names(table_list)
  return(deps)
}
