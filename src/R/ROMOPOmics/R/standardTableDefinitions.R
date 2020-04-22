#' standardTableDefinitions
#'
#' Functions reads in stored definition table and returns it as a tibble.
#'
#' @param definition_table Data file with definitions of OMOP terms and their corresponding names in the standard file. If not provided, defaults to stored default.
#'
#' @import data.table
#' @import tibble
#'
#' standardTableDefinitions()
#'
#' @export

standardTableDefinitions  <- function(definition_table){
  if(missing(definition_table)){
    definition_table  <- system.file("extdata","omop_cdm_tables.csv",package="ROMOPOmics",mustWork = TRUE)
  }
  defs  <- data.table::fread(definition_table,header = TRUE) %>% as_tibble()
  return(defs)
}
