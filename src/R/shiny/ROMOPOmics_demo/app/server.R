shinyServer(function(input, output, session=session) {
  #####################
  #     Reactives     #
  #####################
  query_table   <- reactive({
    dbGetQuery(conn = db,statement = input$db_manual_query)
  })
  filter_table  <- reactive({
    filterTable(filter_cols=input$db_filt_select,
                                        data_model = dm,
                                        db_tables = db_tabs)
  })
  
  #####################
  #    Observations   #
  #####################
  observeEvent(input$db_filt_select,{
    #Get rid of obsolete filters.
    obsoleteFilters(input_list = input,flt_tbl = filter_table()) %>%
      lapply(function(x) 
        removeUI(session = session,
                 selector = paste0("#",x),
                 multiple = TRUE,immediate = FALSE))
  })
  observeEvent(input$db_filt_select,{
    #Add missing filters UI groups.
    missingFilters(input_list = input,flt_tbl=filter_table()) %>%
      lapply(function(x)
        insertUI(
          selector='#nextFilterUI',where = "beforeBegin",
          ui = addFilterUI(flt_name=x),
          multiple = TRUE,immediate = FALSE,session = session))
  })
  observeEvent(input$db_mask,{
    new_choices <- getFields(db_tabs,mask = input$db_mask)
    #Update field selection.
    sels        <- input$db_field_select
    updateSelectInput(session = session,
                      inputId = "db_field_select",
                      choices=new_choices,
                      selected = intersect(sels,new_choices))
    #Update filter selection.
    sels        <- input$db_filt_select
    updateSelectInput(session = session,
                      inputId = "db_filt_select",
                      choices=new_choices,
                      selected = intersect(sels,new_choices))
  })
  
  #####################
  #     Outputs       #
  #####################
  output$db_preview   <- renderDataTable({
    as_tibble(query_table())
  })
  output$flt_tbl      <- renderDataTable({
    filter_table()
  })
  output$db_blurb     <- renderText({
    paste0("Database file saved to '",basename(dirs$db_file),"'\n",
           "Based on ",length(msks)," input masks, ",length(unique(unlist(db_tabs)))," total fields\n",
           "(including indices) from ",length(db_tabs)," tables incorporated:\n\n\t",
           paste(names(db_tabs),collapse="\n\t"))
  })
  output$db_preview   <- renderDataTable(options=list(pageLength=100),{
    as_tibble(query_table())
  })
  output$mask_table   <- renderDataTable(options=list(pageLength=100),{
    msk_sel <- input$mask_select
    msks[[msk_sel]]
  })
  output$mask_blurb   <- renderText({
    msk   <- msks[[input$mask_select]]
    paste0("Mask file: ",input$mask_select,"_mask.tsv\n",
           length(unique(msk$table))," tables and ",length(unique(msk$field))," fields from data model.")
  })
  output$mask_network <- renderPlot({
    msk   <- msks[[input$mask_select]]
    plotTableNetwork(dependency_matrix = getDependencies(dm,return_matrix = TRUE,inc_tabs = tolower(unique(msk$table))),
                     selected = "All",
                     def_cols = "black",def_edge_cols = "darkgray",def_size = 8,def_edge_size = 2,
                     mode_out = input$mask_layout)
  })
  output$model_table  <- renderDataTable(options=list(pageLength=100),{
    tb_sel  <- input$dm_select_table
    tb      <- select(dm,-table_index)
    if(tb_sel != "All"){
      tb    <- filter(tb,table == tb_sel)
    }
    return(mutate(tb,table=toupper(table)))
  })
  output$model_network<- renderPlot({
    plotTableNetwork(dependency_matrix = getDependencies(dm,return_matrix = TRUE),
                     selected = input$dm_select_table,
                     mode_out = input$model_layout,def_cols = "darkgray")
  })
  output$model_blurb  <- renderText({
    paste0("Model file: ",basename(dirs$dm_file),"\n",
           length(unique(dm$table))," tables with ",nrow(dm) - sum(dm$table_index),
                  " unique fields and ",sum(dm$table_index)," index columns")
  })
})