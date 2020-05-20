#' filterTable
#' 
#' 
#' 

filterTable <- function(filter_cols=input$db_filt_select,data_model=dm,db_tables=db_tabs){
  inc_tabs  <- unlist(unique(str_extract(filter_cols,"(^[^\\|]+)")))
  inc_flds  <- unlist(unique(str_extract(filter_cols,"([^\\|]+)$")))
  
  dm %>%
    filter(table %in% inc_tabs) %>%
    filter(field %in% inc_flds) %>%
    mutate(full_name = paste(table,field,sep="|"),
           type = interpret_class(type),
           input_name = paste("flt",type,field,sep=".")) %>%
    select(full_name,table,field,type,input_name) %>%
    return()
  #Possible to pull out choices, summary values, etc., but these will require 
  # the entire column to be queried....not tenable for large datbases.
}



#getFilterVals   <- function(table_name="person",field_name="hla_source_value",type_in="character",db_tables=db_tables){
#  db_tables[[toupper(table_name)]] %>%
#    select(!!as.name(field_name)) %>%
#}