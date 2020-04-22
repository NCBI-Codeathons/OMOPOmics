shinyServer(function(input, output,session) {
  query_trace         <- reactive(queryTrace(inc_cols =input$include_columns,
                                             filt_cols= input$include_filters,
                                             key_tabs = key_tabs,
                                             table_list=tabs))
  filter_table        <- reactive(filterTable(input_list=input,filter_cols=input$include_filters))
  prebuilt_query      <- reactive(databaseQuery(table_list = tabs[query_trace()]) %>%
                                    applyFilters(filter_table = filter_table()))
  output$table_output <- renderDataTable(rownames=FALSE,options=list(rownames=FALSE,pageLength=50),             
                          {prebuilt_query() %>%
                            as_tibble() %>%
                            select(input$include_columns)})
  output$sql_preview  <- renderPrint(show_query(prebuilt_query()))
  output$table_graph  <- renderPlot(
                          plotTableNetworkManual(table_list = tabs,
                                                 inc_tables = query_trace()))
  output$filter_tab   <- renderDataTable(rownames=FALSE,filterTable(input_list = input,
                                                                    filter_cols = input$include_filters))
  observeEvent(input$include_filters,{
    #Remove unused filters UI groups.
    obsoleteFilters(input_list = input,include_cols = input$include_filters) %>%
      lapply(function(x) 
        removeUI(selector = paste0("#",x),multiple = TRUE,immediate = FALSE))
  })
  #Keeping these separate allows <input> to update before figuring out missing filters.
  observeEvent(input$include_filters,{
    #Add new filters UI groups.
    missingFilters(input_list = input,include_cols = input$include_filters) %>%
      lapply(function(x)
        insertUI(
          selector='#nextFilterUI',where = "beforeBegin",
          ui = characterFilterUI(col_name = x,
                                 logic_choices = opt_filter_logic,
                                 logic_selected = opt_filter_logic_def,
                                 direction_choices = opt_filter_direc,
                                 direction_selected = opt_filter_direc_def),multiple = TRUE,immediate = TRUE,session = session))
  })
  output$output_download_btn<- downloadHandler(
    filename =function(){paste0(input$output_filename,ifelse(input$output_sep_sel==",",".csv",".tsv"))},
    content = function(con){
      write.table(as_tibble(prebuilt_query()),
                  con,
                  sep = input$output_sep_sel,
                  quote = FALSE,
                  row.names = FALSE,
                  col.names = ifelse(input$output_header=="Yes",TRUE,FALSE))
    }
  )
})