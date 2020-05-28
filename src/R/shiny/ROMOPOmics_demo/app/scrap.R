#Shiny debug script

input   <- list(db_mask = opt_db_mask_select_def,
                db_field_select=opt_db_field_select_def,
                db_filt_select =opt_db_filt_select_def,
                db_manual_query = opt_db_manual_def,
                dm_select_table=opt_dm_select_table_def,
                mask_select = opt_mask_select_def,
                model_layout=opt_dm_layout_def,
                mask_layout =opt_dm_layout_def)

#Emulate reactives etc.
#query_table <- function() {
#  queryTable(include_cols=input$db_field_select,
#             filter_cols=input$db_filt_select,
#             key_tabs=db_key_tabs,
#             table_list=db_tabs)
#}
query_table   <- function() {
  dbGetQuery(conn = db,statement = input$db_manual_query)
}

filter_table  <- function() {filterTable(filter_cols=input$db_filt_select,data_model=dm,db_tables=db_tabs)}
filter_table()
