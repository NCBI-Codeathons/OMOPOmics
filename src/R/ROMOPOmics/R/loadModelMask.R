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
  masks         <- lapply(mask_files,function(x) as_tibble(fread(x,sep = "\t",header = TRUE)))
  names(masks)  <- gsub("_mask.tsv","",basename(mask_files))

  masks   <- lapply(masks, function(x)
    x %>%
      #Check that set_value and entry_index columns are present, if not add blanks.
      mutate(set_value = if("set_value" %in% names(.)){set_value}else{NA},
             field_idx = if("field_idx" %in% names(.)){field_idx}else{NA},
             set_value = ifelse(set_value=="",NA,set_value),
             field_idx = ifelse(field_idx=="",NA,field_idx)) %>%
      select(table,alias,field,set_value,field_idx,everything())
  )

  if(as_blank){
    return(lapply(masks,function(x) select(x,alias)))
  }else{
    return(masks)
  }
}
