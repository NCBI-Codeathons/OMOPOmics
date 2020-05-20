#' blankOMOPTables
#'
#' Function uses the specified table_defintions file to generate empty tables
#' with formatted columns. If table names are provided, only returns tables
#' with the provided names.
#'
#' @param definition_table Data file with definitions of OMOP terms and their corresponding names in the standard file.
#' @param table_names Names of tables to return, if any. If NULL, returns all tables.
#'
#' @import
#'
#' blankOMOPTables()
#'
#' @export

blankOMOPTables   <- function(definition_table,table_names = NULL){
  om_tib  <- standardTableDefinitions() %>%
              arrange(table_name)

  tibs    <- om_tib %>%
              group_split(table_name) %>%
              lapply( function(x) {
                mtx   <- matrix(nrow=0,ncol=nrow(x))
                colnames(mtx)   <- unlist(select(x,omop_name))
                #tib   <- as_tibble(mtx)
                tib     <- as.data.frame(mtx)
                col_classes     <- unlist(select(x,class))
                for(i in 1:length(col_classes)){
                  class(tib[,i])<- col_classes[i]
                }
                return(as_tibble(tib))
              })
  names(tibs)   <- unique(om_tib$table_name)
  if(is.null(table_names)){
    return(tibs)
  }
  present_tables  <- sapply(table_names, function(x) x %in% names(tibs))
  if(any(!present_tables)){
    message(
      paste0("\nTable(s) not found:\n",
             paste(names(present_tables)[!present_tables],collapse=", "),".\n"))
  }
  if(any(present_tables)){
    return(tibs[names(which(present_tables))])
  }
}
