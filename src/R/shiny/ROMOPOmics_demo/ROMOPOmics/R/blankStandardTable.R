#' inputTable
#'
#' Function returns a blank standard table as a template, given an included master table file.
#'
#' inputTable()
#'
#' @import tibble
#' @import data.table
#'
#' @export

inputTable  <- function(master_table_file){
  if(missing(master_table_file)){
    master_table_file <- system.file("extdata","master_table.tsv",package="ROMOPOmics",mustWork = TRUE)
  }
  #When reading the master table, ignore any field that is:
  # 1. A table ID.
  # 2. Ends with "_id" (these should be mapped, so maybe use them later).
  # 3. Has no alias
  mst_tbl           <- master_table_file %>%
                        fread(header = TRUE,sep = "\t") %>%
                        as_tibble()
  table_indices   <- mst_tbl %>% select(table) %>% unlist(use.names=FALSE) %>% unique() %>% tolower() %>% paste0("_id")
  mst_tbl   <- mst_tbl %>%
                filter(!field %in% table_indices & !grepl("_id$",field) & alias != "") %>%
                mutate(value = "")
  mtx       <- matrix(ncol=nrow(mst_tbl),data = "")
  colnames(mtx)   <- select(mst_tbl,field) %>% unlist(use.names=FALSE)
  return(as_tibble(mtx))
  #template_file     <- system.file("extdata","standard_table_template.tsv",package="ROMOPOmics",mustWork = TRUE)
  #return(as_tibble(data.table::fread(template_file)))
}
