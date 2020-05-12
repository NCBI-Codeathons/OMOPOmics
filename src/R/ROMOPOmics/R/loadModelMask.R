#' loadModelMasks
#'
#' Function reads in all "mask" tables within a directory which include three
#' essential columns: table, alias, and field. 'Alias' denotes the value being
#' input, 'field' denotes the data model's equivalent field name, and 'table'
#' denotes the data model table where that field resides.
#'
#' loadModelMasks
#'
#' @import tibble
#' @import data.table
#' @import magrittr
#'
#' @export

loadModelMasks  <- function(mask_file_directory,data_model=loadDataModel(),as_blank=FALSE){
  if(missing(mask_file_directory)){
    mask_file_directory <- system.file("extdata","masks",package = "ROMOPOmics",mustWork = TRUE)
  }
  mask_files    <- Sys.glob(file.path(mask_file_directory,"*.tsv"))
  masks         <- lapply(mask_files,function(x) as_tibble(fread(x)))
  names(masks)  <- gsub(".tsv","",basename(mask_files))

  #Check for duplicated aliases.
  for(x in names(masks)){
    if(nrow(masks[[x]]) > length(unique(masks[[x]]$alias))){
      message("Duplicated aliases detected in mask table ",x,", these are not allowed.")
    }
  }
  if(as_blank){
    return(lapply(masks,function(x) select(x,alias)))
  }else{
    return(masks)
  }
}
