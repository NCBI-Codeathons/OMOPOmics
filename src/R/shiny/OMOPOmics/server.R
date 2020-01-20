shinyServer(function(input, output) {
  query_map     <- reactive({
    #Summarizes possible filters, their selections, and their inputIDs for
    # use by other functions.
    lapply(names(tabs), function(x) 
      tibble(table_nm=x,
             filter_name=colnames(tabs[[x]])) %>%
        rowwise() %>%
        mutate(filter_id = paste(table_nm,filter_name,"filter",sep="."),
               return_id = paste(table_nm,filter_name,"return",sep="."),
               include_filter=length(input[[filter_id]]) > 0,
               include_return=input[[return_id]]) %>%
        ungroup()) %>%
      do.call(rbind,.)
  })
  prebuilt_query<- reactive({
    #This should be the compiled SQL query; in principal this should not need
    # to be computed and so could be returned as a raw query. To evaluate 
    # either for display or to output to file, this reactive should be
    # computed or converted to a tibble.
    #Basic function: Figure out the minimum number of tables to be inner-joined,
    # then combine them recursively. Next apply filters and select column values
    # of interest. Return BEFORE converting to tibble/computing.
    
    #Pull list of tables to inner_join from query_map()
    qm      <- query_map() %>% 
                filter(include_filter | include_return | table_nm == key_table)
    
    tab_set <- tabs[names(tabs) %in% qm$table_nm]
    if(length(tab_set) > 1){
      #If more than one table is required, inner_join recursively.
      db    <- Reduce(inner_join,tab_set)
    }else if(length(tab_set) == 1){
      #If only one table is requested, return it.
      db    <- tab_set[1]
    }else{
      #If no tables are requested, return NULL.
      db    <- NULL
    }
    if(!is.null(db)){
      if(select(query_map(),include_filter) %>% unlist() %>% sum() == 0){
        #Get filters from query_map(), if any are present.
        filts   <- NULL
      }else{
        filts   <- query_map() %>%
                    filter(include_filter) %>%
                    select(filter_name,filter_id) %>%
                    rowwise() %>%
                    mutate(filt_vals = list(input[[filter_id]])) %>%
                    ungroup() %>%
                    group_by(filter_name) %>%
                    summarize(filt_vals = list(unique(unlist(filt_vals)))) %>%
                  vectify(name_col = "filter_name",value_col = "filt_vals")
        #Get selected columns from query_map().
        sels    <- query_map() %>%
                    filter(include_return) %>%
                    select(filter_name) %>%
                    unlist(use.names=FALSE) %>%
                    unique()
        db      <- db %>%
                    stacked_filters(filter_list=filts,exclude=FALSE) %>%
                    select(sels)
      }
    }
    return(db)
  })
  output$table_output   <- renderDataTable(rownames=FALSE,options=list(rownames=FALSE,pageLength=50),{
    as_tibble(prebuilt_query())
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
  output$sql_preview        <- renderPrint(show_query(prebuilt_query()))
})