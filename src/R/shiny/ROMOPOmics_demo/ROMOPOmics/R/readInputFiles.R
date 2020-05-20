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

readInputFiles    <- function(input_file = input_files[[2]],
                              data_model = dm,
                              mask_table = msks$patient_sequencing){
  #Get file names to append to each column.
  fl_nm   <- str_match(basename(input_file),"(.+)\\.tsv$")[,2]
  #Merge input file into the full data model.
  in_tab  <- fread(input_file,sep = "\t",header = FALSE,stringsAsFactors = FALSE) %>%
              rename(alias=1) %>%
              merge(.,select(mask_table,table,alias,field),all.x = TRUE, all.y=TRUE) %>%
              as_tibble() %>%
              rename_at(vars(starts_with("V")), function(x) gsub("V",fl_nm,x)) %>%
              select(table,field,everything(),-alias)

  #The "standard table" now is the entire data model with mapped inputs, all
  # unspecified values as NA. Each individual entry is stored in unique column.
  data_model %>%
    select(field,table,required,type,description,table_index) %>% #Only keep standard cols.
    mutate(table=toupper(table)) %>%
    merge(in_tab,all=TRUE) %>%
    as_tibble() %>%
    mutate_all(function(x) ifelse(x=="",NA,x)) %>%
    return()
}
