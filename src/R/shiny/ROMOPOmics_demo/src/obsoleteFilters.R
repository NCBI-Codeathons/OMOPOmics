#' obsoleteFilters
#' 
#' Function scans the <input> list for any filters present that shouldn't be
#' given the existing filter table.

obsoleteFilters   <- function(input_list = input, flt_tbl = filter_table()){
  #Get names of all current filters.
  curr_flts     <- names(input_list)[grepl("^flt",names(input_list))]
  obso_flts     <- curr_flts[!curr_flts %in% select(flt_tbl,input_name) %>% unlist()]
  if(identical(obso_flts,character(0))){
    return(NULL)
  }else{
    return(obso_flts)
  }
}