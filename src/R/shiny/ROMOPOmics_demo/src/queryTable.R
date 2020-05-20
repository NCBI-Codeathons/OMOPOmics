#' queryTable
#' 
#' Function takes in a list of columns required for data output (include_cols)
#' and a list of columns required for filtering (filter_cols) and inner_joins 
#' the required tables to create the requisite table with all columns included.
#' "Key" (required) tables are also included for network purposes.
#' 
#' @param include_cols Columns required for output.
#' @param filter_cols Columns required for filtering.
#' @param key_tabs Tables that should be included no matter what for the purposes of assuring network dependencies.
#' @param table_list List of tables in the current database (typically returned by getDBTables()).
#' 
#' queryTable()
#' 
#' @import dplyr
#' @import tibble
#' 
#' @export

queryTable  <- function(include_cols=input$db_field_select,
                        filter_cols =input$db_filt_select,
                        key_tabs=db_key_tabs,
                        table_list=db_tabs){
  #All tables to include:
  in_tabs   <- c(key_tabs,
                 str_extract(include_cols,"^[^\\|]+"),
                 str_extract(filter_cols ,"^[^\\|]+")) %>%
                unique() %>% toupper()
  Reduce(inner_join,table_list[in_tabs]) %>%
    return()
}
