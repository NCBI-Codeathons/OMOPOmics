#!/bin/Rscript
#Return list of filters for which there are no UI elemnets present.
# i.e., if filters A, and B are present in the UI but filter C is added to the
# include_filters input, return the name of the missing filter elements
# (for removal).
missingFilters  <- function(input_list,include_cols){
  curr_flts     <- names(input_list)[grepl("^flt",names(input_list))] %>%   #All filter prefixes.
                    str_match("^flt\\.[:alpha:]{3}\\.([^\\.]+)")
  curr_flts     <- unique(curr_flts[,2,drop=FALSE])
  miss_flts     <- include_cols[!include_cols %in% curr_flts]
  if(identical(miss_flts,character(0))){
    return(NULL)
  }else{
    return(miss_flts)
  }
}
