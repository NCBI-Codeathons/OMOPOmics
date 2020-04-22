#' parseToOMOP.R
#'
#' Given a formatted input table, function first renames columns to their
#' corresponding OMOP term. Next, compileID() is used to append an index column
#' for each OMOP table to be built.
#'
#' @param standard_table Standard table, typically the output of readStandardTables().
#'
#' @import tidyverse
#' @import data.table
#' @import stringr
#' @import tibble
#'
#' parseToOMOP
#'
#' @export

parseToOMOP <- function(standard_table){
  rename    <- dplyr::rename
  defs      <- standardTableDefinitions() %>% filter(std_name != "")
  std_nms   <- select(defs,std_name) %>% unlist() %>% unique()
  omop_nms  <- select(defs,omop_name) %>% unlist() %>% unique()
  if(length(std_nms) != length(omop_nms)){
    stop("\n\nDifferent numbers of (unique) standard table names (",length(std_nms),") and OMOP table definitions (",length(omop_nms),").")
  }
  names(omop_nms) <- std_nms

  tib   <- standard_table %>%
            data.table::setnames(old = std_nms,new = omop_nms,skip_absent = TRUE) %>%
            mutate(gender_concept_id=genderConceptID(gender_source_value))
  #Append IDs for each OMOP table.
  omop_tabs <- blankOMOPTables()
  for(nm in names(omop_tabs)){
    id_col  <- paste0(nm,"_id")
    #Skip table if ID column already present.
    if(!id_col %in% colnames(tib)){
      id_pfx  <- stringr::str_split(nm,pattern = "_",simplify = TRUE) %>%
                  stringr::str_extract("^[:alpha:]") %>%
                  toupper() %>%
                  paste(collapse="")
      col_nms <- colnames(omop_tabs[[nm]])
      tib     <- tib %>% compileID(id_column = id_col,id_pfx = id_pfx,inc_columns = col_nms)
    }
  }
  return(tib)
}
