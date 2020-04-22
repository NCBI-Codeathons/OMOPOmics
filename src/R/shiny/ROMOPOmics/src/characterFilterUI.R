#!/bin/Rscript
#Add character filter panel.
# Returns a filter panel UI element for a filter meant for character values.

characterFilterUI <- function(col_name="gender_source_value",
                              logic_choices = opt_filter_logic,logic_selected=opt_filter_logic_def,
                              direction_choices=opt_filter_direc,direction_selected=opt_filter_direc_def){
  flt_name  <- paste0("flt.txt.",col_name)
  flt_logic <- paste0(flt_name,".logic")
  flt_txt   <- paste0(flt_name,".txt")
  #flt_direct<- paste0(flt_name,".direct")
  
  list(
    div(id=col_name, #Use of div() allows for removeUI() to find all of these elements.
      h3(col_name),
      fluidRow(
        column(5,selectInput(inputId=flt_logic,label = NULL,choices = opt_filter_logic,
                             multiple = FALSE,selected = 1)),
        column(7,textInput(inputId=flt_txt,label = NULL,value = ""))#,
        #column(3,selectInput(inputId=flt_direct,label=NULL,choices=opt_filter_direc,
         #                    multiple = FALSE,selected = 1))
      )
    )
  ) %>%
  return
}
