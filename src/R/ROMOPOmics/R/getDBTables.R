#' getDBTables
#'
#' Given a database object, function returns all attached tables in a list. If
#' find_key = TRUE, function calls getTableDependencies() to identify which
#' tables in the list are dependent on others, and attempts to find at least
#' one table with no dependencies. If any are found, they are moved to
#' the front of the list such that later query functions should always include
#' at least one of them to ensure that a path between tables exists for all
#' possible queries.
#'
#' @param database_object A built SQLite database object, typically output by dbOMOP().
#' @param find_key Boolean; if TRUE, getTableDependencies() is used to identify and sort tables by dependencies.
#' @param quiet Boolean; if TRUE, messages are reported for find_key steps (either names of independent tables or a warning that none were found).
#'
#' getDBTables()
#'
#' @import tibble
#' @import DBI
#' @import data.table
#' @import RSQLite
#'
#' @export

getDBTables   <- function(database_object,find_key=TRUE,quiet=FALSE){
  table_nms   <- dbListTables(database_object)
  tables      <- lapply(table_nms, function(x) tbl(database_object,x))
  names(tables) <- table_nms

  if(find_key){
    #Get dependencies and identify "key" (independent) tables. Move all such
    # tables to the front of the list, but other than that order is just
    # alphabetical...so meaningless.
    deps        <- getTableDependencies(tables)
    key_tables  <- which(sapply(deps,identical,character(0)))
    if(length(key_tables)>0){
      tables    <- c(tables[key_tables],tables[-key_tables])
    }
    if(!quiet){
      if(length(key_tables)>0){
        message("Table",ifelse(length(key_tables)>1,"s","")," '",
                paste(names(key_tables),collapse="', '"),"' ",
                ifelse(length(key_tables)>1,"are","is")," independent.")
      }else{
        message("Warning: No independent tables identified.")
      }
    }
  }
  return(tables)
}
