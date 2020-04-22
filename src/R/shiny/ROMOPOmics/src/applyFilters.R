#!/bin/Rscript
#applyFilters
# Given the query table and a compiled filter table, this function iteratively
# applies each filter (one per row of the table) based on the filter's type
# indicated in the "type" column. For instance, a filter of type "txt" is
# applied using the characterFilter() function.

applyFilters  <- function(query_in  = qu,filter_table =ft){
  if(is.null(filter_table)){return(query_in)}
  query_out   <- query_in
  for(i in 1:nrow(filter_table)){
    if(filter_table[i,"type"]=="txt"){
      query_out <- filterCharacter(query_in=query_out,
                                   col_in = unlist(filter_table[i,"flt_col_name"]),
                                   txt_in = unlist(filter_table[i,"txt"]),
                                   logic_in=unlist(filter_table[i,"logic"]))
    }
  }
  return(query_out)
}
#applyFilters()
