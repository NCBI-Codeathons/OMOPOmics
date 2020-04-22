#!/bin/Rscript
#Query trace
# Function accepts the columns needed for inclusion and for filtering, and approximates (identifies?)
# the minimum tables required for the query. First, it identifies all tables that feature one or more of
# the required columns, and sorts by number of tables containing them, so columns that are only present
# in one table are included by default. Next, the function iterates through each table and each time
# determines which columns are currently included. If columns are still missing, adds the next table
# and repeats. Once all required columns are present, stops adding tables. This way as few tables are
# incorporated as possible, while still featuring all columns needed.
#For now, require that any table with more than one dependent table is included.

queryTrace<- function(inc_cols,filt_cols,key_tabs,table_list){
  #Get required tables, i.e. minimum tables that will include all requested columns.
  req_cols<- unique(c(inc_cols,filt_cols))
  req_tabs<- c(key_tabs)
  max_tabs<- tabQueryTable() %>%
              filter(omop_name %in% req_cols) %>%
              rowwise() %>%
              mutate(tabs=length(table_names)) %>%
              ungroup() %>%
              arrange(tabs)
  inc_cols<- unique(unlist(lapply(key_tabs, function(x) colnames(table_list[[x]]))))
  blnk_tbs<- blankOMOPTables()
  for(tb in unique(unlist(max_tabs$table_names))){
    if(!all(req_cols %in% inc_cols)){
      req_tabs  <- c(req_tabs,tb)
      inc_cols  <- c(inc_cols,colnames(blnk_tbs[[tb]])) %>% unique()
    }
  }
  req_tabs  <- unique(req_tabs)
  return(unique(req_tabs))
}
