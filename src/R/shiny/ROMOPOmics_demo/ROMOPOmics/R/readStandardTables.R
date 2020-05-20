#' readStandardTables.R
#'
#' Given a list of standardized table CSV files, function reads each and incorporates
#' into a single data frame, with each annotated with an "experiment" column
#' containing the basename of the origin file.
#'
#' @param standard_table_files List of CSV files to incorporate.
#'
#' @import data.table
#' @import dplry
#' @import tibble
#'
#' readStandardTables
#'
#' @export

readStandardTables<- function(input_files){
  st_fls        <- standard_table_files
  names(st_fls) <- gsub("\\.tsv","",basename(st_fls))
  lapply(names(st_fls), function(x)
    data.table::fread(st_fls[[x]],header = TRUE) %>%
      as_tibble() %>%
      mutate(experiment=x)) %>%
    do.call(rbind,.)
}
