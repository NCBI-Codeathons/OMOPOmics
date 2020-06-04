#TCGA data model

library(tidyverse)
library(data.table)
library(RTCGA.clinical)
library(RTCGA.mutations)

clin  <- RTCGA.clinical::BRCA.clinical %>% 
          as_tibble() %>%
          melt(id.vars = "patient.bcr_patient_barcode")
parse_block_name  <- function(block_string="patient.additional_studies.additional_study.disease_code"){
  return(list(unique(gsub("[0123456789]+$","",unlist(str_split(block_string,pattern = "\\."))))))
}

vars  <- tibble(column_name=levels(clin$variable)) %>%
          rowwise() %>%
          mutate(blocks = parse_block_name(column_name)) %>%
          unnest(blocks) %>%
          group_by(column_name) %>%
          mutate(block_index = row_number()) %>% 
          ungroup() %>%
          spread(value = blocks,key = block_index)
vars %>%
  group_by(`1`) %>%
  summarize(`2`=list(unique(`2`)))


get_sub_vars  <- function(var_name="admin",var_tab = select(vars,-1),col_idx=1){
  if(ncol(var_tab) < col_idx+1){
    return(NULL)
  }
  cnms  <- colnames(var_tab)[c(col_idx,col_idx+1)]
  vals  <- var_tab %>% 
            rename(top_val=!!as.name(cnms[1]),
                   bot_val=!!as.name(cnms[2])) %>%
            filter(top_val == var_name) %>%
            summarize(vars=list(unique(bot_val))) %>%
            select(vars) %>%
            unlist(use.names=FALSE) %>%
            unique()
  if(length(vals) < 1){
    return(NULL)
  }
  #return(vals)
  return(sapply(vals,function(x) get_sub_vars(x,col_idx = col_idx+1)))
}

x <- sapply(unique(vars$`1`), function(x) get_sub_vars(var_name = x,col_idx = 1))
