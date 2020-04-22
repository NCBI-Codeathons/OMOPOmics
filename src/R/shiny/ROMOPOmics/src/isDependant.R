#!/bin/Rscript
#isDependent
# Given two table names, return TRUE or FALSE if the subject table is dependent
# on the query table (includes the subject table's ID column). IDs are assumed
# to be the table name with "_id" added.

isDependant <- function(subj_tab,quer_tab,one_way=FALSE,table_list){
  #Is <subject> dependent on <query>?
  table_ids <- paste(names(table_list),"_id")
  if(subj_tab == quer_tab){return(FALSE)}
  quer_id   <- paste(quer_tab,"id",sep="_")
  subj_cols <- colnames(tabs[[subj_tab]])
  dep       <- quer_id %in% subj_cols
  if(one_way){
    return(dep)
  }else{
    return(dep | isDependent(quer_tab,subj_tab,one_way=TRUE))
  }
}
