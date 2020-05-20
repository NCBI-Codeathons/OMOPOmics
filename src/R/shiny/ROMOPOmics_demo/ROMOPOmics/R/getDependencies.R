#' getDependencies
#'
#' Function accepts a data model from loadDataModel() and returns a list of
#' dependencies between constitutive tables based on the presence of index
#' columns (columns that end with "<table_name>_id").
#'
#' @param data_model Data model from loadDataModel(), in single-table format.
#' @param inc_tabs Only include tables with these names.
#' @param return_matrix Return dependencies as integer-format matrix of directional connections.
#'
#' getDependencies()
#'
#' @import tibble
#'

getDependencies   <- function(data_model=loadDataModel(),inc_tabs,return_matrix=FALSE){
  if(missing(inc_tabs)){
    inc_tabs  <- unique(data_model$table)
  }
  tb  <- data_model %>%
          filter(table %in% inc_tabs) %>%
          filter(table_index) %>%
          group_by(table) %>%
          select(field,table) %>%
          mutate(field=gsub("_id","",field)) %>%
          filter(field %in% inc_tabs) %>%
          summarize(dependencies=list(field))
  dep_lst   <- tb$dependencies
  names(dep_lst)  <- tb$table
  dep_lst   <- dep_lst[order(names(dep_lst))]
  #Omit self-depenedency.
  dep_lst   <- lapply(names(dep_lst), function(x) {
                lst_ot<- dep_lst[[x]]
                lst_ot<- lst_ot[lst_ot != x]
                return(lst_ot)})
  names(dep_lst)  <- tb$table
  if(return_matrix){
    dep_lst           <- sapply(dep_lst,function(x) as.integer(names(dep_lst) %in% x))
    rownames(dep_lst) <- colnames(dep_lst)
  }
  return(dep_lst)
}


#getDeps(return_matrix = TRUE,inc_tabs = c("person","specimen","sequencing","condition_occurrence","cohort_definition","drug_exposure"))
