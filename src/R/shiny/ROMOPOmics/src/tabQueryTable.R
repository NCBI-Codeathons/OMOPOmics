#!/bin/Rscript
#Query table: table is displayed on the left-hand column and includes all available filters.

tabQueryTable   <- function(table_filt="all",include_checks=FALSE){
  tb  <- standardTableDefinitions() %>%
          select(table_name,omop_name,class) %>%
          group_by(omop_name,class) %>%
          summarize(table_names=list(table_name)) %>%
          mutate(include= FALSE,
                 filter = FALSE) %>%
          ungroup()
  if(table_filt!="all"){
    tb<- tb %>%
          rowwise() %>%
          filter(any(table_filt %in% table_names)) %>%
          ungroup()
  }
  if(include_checks){
    tb$cbx.inc  <- shinyInput(FUN = checkboxInput,id_pfx = "cbx.inc",id_col = tb$omop_name,val_col = tb$include)
    tb$cbx.flt  <- shinyInput(FUN = checkboxInput,id_pfx = "cbx.flt",id_col = tb$omop_name,val_col = tb$filter)
  }
  return(tb)
}

