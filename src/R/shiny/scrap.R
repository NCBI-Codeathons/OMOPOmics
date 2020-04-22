output$query_table    <- DT::renderDataTable(rownames=FALSE,
                                             options=list(rownames=FALSE,pageLength=50,
                                                          drawCallback= JS(
                                                            'function(settings) {
                                                            Shiny.bindAll(this.api().table().node());}')),escape=FALSE,{
                                                              tb  <- tabQueryTable(include_checks = TRUE) %>%
                                                                ungroup()
                                                              if(input$query_table_filter!="all"){
                                                                tb<- tb %>%
                                                                  rowwise() %>%
                                                                  filter(any(table_names %in% input$query_table_filter)) %>%
                                                                  ungroup()
                                                              }
                                                              tb %>%
                                                                select(omop_name,starts_with("cbx"))
                                                              })
shinyInput <- function(FUN,id_pfx,id_col,val_col) {
  inputs  <- lapply(1:length(id_col), function(i){
    id  <- id_col[i]
    val <- val_col[i]
    nm  <- paste(id_pfx,id,sep=";")
    as.character(FUN(nm,label=NULL,val))
  })
  return(inputs)
}
incSelect <- reactive({
  idx     <- names(input)[grepl(pattern = "^cbx.inc",names(input))]
  nms     <- str_extract(idx,"[^;]+$")
  inc     <- unlist(sapply(idx, function(x) input[[x]]))
  return(nms[inc])
})
fltSelect <- reactive({
  idx     <- names(input)[grepl(pattern = "^cbx.flt",names(input))]
  nms     <- str_extract(idx,"[^;]+$")
  inc     <- unlist(sapply(idx, function(x) input[[x]]))
  return(nms[inc])
})
observe({
  updateTextInput(session, "inc_txt", value = paste(incSelect(),collapse=",") ,label = "Include:" )
  updateTextInput(session, "flt_txt", value = paste(fltSelect(),collapse=",") ,label = "Filter:" )
})


input   <- list(flt.txt.gender_source_value.logic="contains",
                flt.txt.gender_source_value.txt = "male",
                flt.num.number_value.type="num",
                flt.num.number_value.min= 10,
                control_2="Apples!",
                flt.num.number_value.max=100,
                flt.num.number_value.logic="within",
                control_3="steves_house")



