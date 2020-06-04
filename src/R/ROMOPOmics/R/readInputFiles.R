#' readInputFiles
#'
#' Function reads in TSV files designed with a given mask in mind, with rows
#' for each field and table combination and columns for input data entries.
#' Output is an "exhaustive" table including all fields and tables from the
#' specified data model, including unused tables and fields.
#'
#' @param input_file Name of a TSV file containing required alias column names.
#' @param data_model Data model being used, typically as a tibble returned by loadDataModel().
#' @param mask_table Mask contained in a tibble, typically as a tibble loaded by loadModelMask().
#'
#' readInputFiles
#'
#' @import tibble
#' @import data.table
#' @import magrittr
#'
#' @export

readInputFiles    <- function(input_file = input_files[[1]][1],
                              data_model = dm,
                              mask_table = msks$brca_clinical){
  #Get file names to append to each column.
  fl_nm   <- str_match(basename(input_file),"(.+)\\.[ct]sv$")[,2]
  #Merge input file into the full data model.
  in_tab  <- fread(input_file,header = FALSE,stringsAsFactors = FALSE) %>%
              rename(alias=1) %>%
              merge(.,select(mask_table,table,alias,field,field_idx,set_value),all.x = TRUE, all.y=TRUE) %>%
              as_tibble() %>%
              rename_at(vars(starts_with("V")), function(x) gsub("V",fl_nm,x)) %>%
              select(table,field,field_idx,alias,set_value,everything())

  #If a set_value was provided, change all corresponding table values to that.
  set_vals<- in_tab %>% select(set_value) %>% unlist(use.names=FALSE)
  in_tab[which(!is.na(set_vals)),colnames(in_tab)[grepl(fl_nm,colnames(in_tab))]] <- set_vals[which(!is.na(set_vals))]

  expand_entry_columns  <- function(table_in = a,col_nms = c("brca_clinical2","brca_clinical3")){

    #If no index values are provided, skip the whole thing.
    if(all(is.na(table_in$set_value))){return(table_in)}

    #Base table: values with no index, meaning they should be common between all
    # other measurements (date of birth applies between all measurements).
    lapply(col_nms, function(x)
    { tb          <- select(table_in,table,field,field_idx,alias,!!as.name(x))
      base_table  <- filter(tb,is.na(field_idx)) %>% select(-field_idx,-alias)
      dupd_tabs   <- filter(tb,!is.na(field_idx)) %>%
                      group_split(field_idx) %>%
                      lapply(function(y) {
                        cn  <- paste(x,y$field_idx[1],sep="_")
                        select(y,table,field,x) %>%
                        rbind(base_table,.) %>%
                        rename(!!as.name(cn):=x)}) %>%
                      Reduce(function(a,b) merge(a,b,all=TRUE),.)
    }) %>%
    Reduce(function(a,b) merge(a,b,all=TRUE),.) %>% as_tibble()
  }
  #st_tm1   <- Sys.time()
  out_tab   <- expand_entry_columns(in_tab,col_nms = colnames(in_tab)[grepl(fl_nm,colnames(in_tab))])
  #en_tm1    <- Sys.time()
  #en_tm1 - st_tm1

  #Full reduce: 1.6 minutes
  #Partial reduce: 39.9 seconds

  #The "standard table" now is the entire data model with mapped inputs, all
  # unspecified values as NA. Each individual entry is stored in unique column.
  data_model %>%
    select(field,table,required,type,description,table_index) %>% #Only keep standard cols.
    mutate(table=toupper(table)) %>%
    merge(out_tab,all=TRUE) %>%
    as_tibble() %>%
    mutate_all(function(x) ifelse(x=="",NA,x)) %>%
    distinct() %>%
    return()
}
