#' loadDataModel
#'
#' Function reads in "official" data model and returns as tibble (and list of
#' tables). By default, points to "cutom" version of the OMOP data model which
#' includes the "Sequencing" table and the hla_type field in "Person".
#'
#' @param master_table_file File containing the total data model used, including "field", "required", "type", "description" and "table" fields.
#' @param as_table_list If TRUE, return the data model split into a list of tables rather than as one solid table.
#'
#' loadDataModel()
#'
#' @import tibble
#' @import data.table
#' @import magrittr
#'
#' @export

loadDataModel <- function(master_table_file,
                          as_table_list = FALSE){
  if(missing(master_table_file)){
    master_table_file <- system.file("extdata","OMOP_CDM_v6_0_custom.csv",package="ROMOPOmics",mustWork = TRUE)
  }
  #When reading the master table, ignore any field that is:
  # 1. A table ID.
  # 2. Ends with "_id" (these should be mapped, so maybe use them later).
  # 3. Has no alias
  mst_tbl       <- master_table_file %>%
                    fread(header = TRUE,sep = ",") %>%
                    as_tibble()
  table_indices <- mst_tbl %>% select(table) %>% unlist(use.names=FALSE) %>% unique() %>% tolower() %>% paste0("_id")
  mst_tbl       <- mst_tbl %>%
                    mutate(table_index = field %in% table_indices)
  if(as_table_list){
    tbl_lst     <- mst_tbl %>%
                  group_by(table) %>%
                  group_split()
    names(tbl_lst)<- sapply(tbl_lst, function(x) toupper(x$table[1]))
    tbl_list    <- lapply(tbl_lst, function(x) select(x,-table))
    return(tbl_lst)
  }else{
    return(mst_tbl)
  }
}
