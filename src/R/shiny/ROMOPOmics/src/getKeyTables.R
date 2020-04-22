#!/bin/Rscript
#Identify tables with dependencies.
# Replace this script later if this turns out to be a less-than-ideal way to do it.

getKeyTables  <- function(table_list=tabs){
  sapply(names(table_list), function(x)
    sapply(names(table_list), function(y) isDependant(subj_tab = y,
                                                      quer_tab = x,
                                                      one_way = TRUE,
                                                      table_list = table_list))) %>%
    as.data.frame %>%
    rownames_to_column("dependant") %>%
    as_tibble %>%
    melt(id.vars="dependant",value.name="depended_on",variable.name="table") %>%
    filter(depended_on) %>%
    select(table) %>%
    unlist(use.names=FALSE) %>%
    as.character %>%
    unique %>%
    return
}
