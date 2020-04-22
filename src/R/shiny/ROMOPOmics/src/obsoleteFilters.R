#!/bin/Rscript
#Return list of current UI elements for filters which are not included in the include_filters list.
# i.e., if filters A, B, and C are present in the UI but filter B is removed
# from the include_filters input, return the ID of all UI components for filter B 
# (for removal).
obsoleteFilters <- function(input_list,include_cols){
  curr_flts     <- names(input_list)[grepl("^flt",names(input_list))] %>%   #All filter prefixes.
                    str_match("^flt\\.[:alpha:]{3}\\.([^\\.]+)")
  curr_flts     <- unique(curr_flts[,2,drop=FALSE])
  obso_flts     <- curr_flts[!curr_flts %in% include_cols]
  if(identical(obso_flts,character(0))){
    return(NULL)
  }else{
    return(obso_flts)
  }
}
