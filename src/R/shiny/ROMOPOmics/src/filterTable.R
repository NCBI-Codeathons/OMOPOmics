#!/bin/Rscript
#Filter table.
# Given an input list, identify all filters and combine into a table
# summarizing them or use. Assumes that exclusively filter control elements 
# are prefixed with "$flt[num].<detail>" names.

filterTable <- function(input_list,filter_cols){
  tb  <- tibble(ctrl_name=names(input_list)) %>%
          filter(grepl("^flt",ctrl_name))
  if(nrow(tb)==0){return(NULL)}
  tb %>%
    rowwise() %>%
    mutate(ctrl_vals=as.character(input_list[[ctrl_name]])) %>%
    ungroup() %>%
    mutate(type = str_match(ctrl_name,"^flt\\.([:alpha:]{3})")[,2],
           flt_col_name=str_match(ctrl_name,"^flt\\.[:alpha:]{3}\\.([^\\.]+)")[,2],
           val_name=str_extract(ctrl_name,"[^\\.]+$")) %>%
    select(-ctrl_name) %>%
    spread(key = val_name,value = ctrl_vals) %>%
    filter(flt_col_name %in% filter_cols) %>%
    return
}
#ft  <- filterTable(input_list=input_list,filter_cols=c("gender_source_value","number_value"))
