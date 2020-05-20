#' getFields
#' 
#' Function returns a vector of fields that can be used to specify columns in 
#' the database tables. Since these values are frequently duplicated between 
#' tables in the OMOP data model, all values are specified as 
#' '<table_name>|<field_name>'. If the specified column does not have a 
#' duplicate, it is labeled with its standard name. If it IS duplicated, it is
#' named '<table_name>_<field_name>. Further, if a mask is provided the 
#' function applies it in the same fashion and returns a vector in the format of
#' '<table_name>|<alias_name>' and '<table_name>_<alias_name>'. All values not
#' specified in the chosen mask are omitted, even if they're otherwise present
#' in the database.

getFields     <- function(model_tables = db_tabs,data_model=dm,mask="patient_sequencing"){
  if(tolower(mask)=="none"){
    alias_col <- "field"
  }else{
    alias_col <- paste0(mask,"_alias")
  }
  tb  <- dm %>% 
          filter(toupper(table) %in% names(db_tabs)) %>%
          mutate(full_name = paste(table,field,sep="|")) %>%
          select(full_name,table,field,ends_with("alias")) %>%
          mutate(field = !!as.name(alias_col)) %>%
          filter(!is.na(field)) %>%
          group_by(field) %>%
          mutate(dupd = n() > 1) %>%
          ungroup() %>%
          mutate(lab = ifelse(dupd,paste(table,field,sep="_"),field))
  vals<- tb$full_name
  names(vals) <- tb$lab
  return(vals)
}
#getFields(mask = "none")
#getFields(mask = "patient_sequencing")
#getFields(mask = "cell_line_sequencing")