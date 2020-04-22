#!/bin/Rscript
#filterCharcter
# This function contains the variations of a filter applied to character-type
# columns. Expects the input query (query_in), a column name (col_in), text 
# value (txt_in), and a string representing how the search is applied 
# (logic_in; can be "is","is not","contains","does not contain").

filterCharacter  <- function(query_in,col_in="gender_source_value",txt_in="male",logic_in="contains"){
  if(txt_in==""){
    return(query_in)
  }else{
    if(logic_in == "is"){
      query_in %>% filter(!!as.name(col_in)==txt_in) %>% return()
    }else if(logic_in=="is not"){
      query_in %>% filter(!!as.name(col_in)!=txt_in) %>% return()
    }else if(logic_in=="contains"){
      query_in %>% filter(!!as.name(col_in) %like% txt_in) %>% return()
    }else if(logic_in=="does not contain"){
      query_in %>% filter(!!as.name(col_in) %not like% txt_in) %>% return()
    }
  }
}