#' blankStandardTable
#'
#' Function returns a blank standard table as a template.
#'
#' blankStandardTable()
#'
#' @import tibble
#' @import data.table
#'
#' @export

blankStandardTable  <- function(){
  template_file     <- system.file("extdata","standard_table_template.tsv",package="ROMOPOmics",mustWork = TRUE)
  return(as_tibble(data.table::fread(template_file)))
}
