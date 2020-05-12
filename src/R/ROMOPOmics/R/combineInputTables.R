#' combineInputTables
#'
#' Given a list of input tables converted into the "exhaustive" format of the
#' data model using readInputFiles(), convert all of these from all masks into
#' a single table, eliminate all unused OMOP tables, and index according to
#' each included table's unique permutations of data. Once complete, return the
#' data model's definition of tables including formatting for type as a list of
#' tibbles that can be submitted to buildSQLDBR.R.
#'
#' @param input_table_list List of tables for inclusion, typically from readInputFiles() with different masks but the same base data model.
#'
#' combineInputTables()
#'
#' @import tibble
#' @import data.table
#' @import magrittr
#'
#' @export

combineInputTables  <- function(input_table_list=lapply(seq_input_files,readInputFiles)){
  #Combine entire list of input tables since they should be identically
  # formatted now, just with different NA columns. Function assumes all data
  # sets are here at this point, including all mask types, for indexing
  # purposes.

  #Reference that includes ALL columns, including IDs and fields with identical names.
  full_tb   <- as_tibble(do.call(merge,input_table_list)) %>%
                mutate(table_field = paste(table,field,sep="|"))
  #Figure out used OMOP tables (those with any input fields).
  used_tbs  <- full_tb %>%
    select(-field,-required,-type,-description,-table_index,-table_field) %>%
    mutate(is_used=rowSums(!is.na(select(.,-table)))>0) %>%
    filter(is_used) %>%
    select(table) %>% unlist(use.names=FALSE) %>% unique()
  full_tb   <- filter(full_tb,table %in% used_tbs)

  #Col_data contains all meta data for each field.
  col_data  <- select(full_tb,table_field,field,table,required,type,description,table_index)

  #tb is a minimal tibble with a table|field column that indexes back to the full table.
  tb        <- filter(full_tb,!table_index) %>%
    select(table_field,everything(),-field,-table,-required,-type,-description,-table_index)
  cn        <- tb$table_field
  tb        <- tb %>%
                select(-table_field) %>%
                as.matrix() %>% t() %>%
                as_tibble(.name_repair = "minimal")
  colnames(tb)<- cn
  tbl_names <- unique(col_data$table)
  for(tb_name in rev(tbl_names)){
    idx_col   <- paste0(tb_name,"|",tolower(tb_name),"_id")
    flds      <- col_data %>% filter(table==tb_name,!table_index) %>% select(table_field) %>% unlist(use.names=FALSE)
    tb        <- tb %>%
      group_by_at(flds) %>%
      mutate(!!as.name(idx_col):=group_indices()) %>%
      select(!!as.name(idx_col),everything()) %>%
      ungroup()
  }

  #Return a list of formatted OMOP tables.
  tbl_lst      <- vector(mode = "list",length = length(tbl_names))
  names(tbl_lst) <- tbl_names
  for(tb_name in rev(tbl_names)){
    cd        <- filter(col_data,table==tb_name) %>%
      arrange(!table_index)
    all_cols  <- filter(cd,!table_index) %>% select(table_field) %>% unlist(use.names=FALSE)
    idx_cols  <- cd %>% filter(table_index) %>% select(field) %>% unlist(use.names=FALSE)
    col_types <- interpret_class(cd$type)
    names(col_types)  <- cd$table_field
    tb_out    <- select(tb,ends_with(idx_cols),all_cols)

    for(i in all_cols){
      class(tb_out[[i]])<- interpret_class(filter(cd,table_field==i) %>% select(type) %>% unlist())
    }
    tbl_lst[[tb_name]]  <- rename_all(tb_out,function(x) str_extract(x,"[^\\|]+$")) %>%
                            distinct()
  }
  return(tbl_lst)
}
