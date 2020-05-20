#' missingFilters
#' 
#' Function scans the <input_list> for filters corresponding to each row in the
#' existing <filter_table>, and if it doesn't find them returns them.

missingFilters  <- function(input_list=input,flt_tbl=filter_table()){
  #Get names of filters already present.
  curr_flts     <- names(input_list)[grepl("^flt",names(input_list))]
  #Get names of missing filters.
  miss_flts     <- select(flt_tbl,input_name) %>% unlist(use.names=FALSE)
  miss_flts     <- miss_flts[!miss_flts %in% curr_flts]
  
  if(identical(miss_flts,character(0))){
    return(NULL)
  }else{
    return(miss_flts)
  }
}