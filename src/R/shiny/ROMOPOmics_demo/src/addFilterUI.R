#' addFilterUI
#' 
#' Given a filter name in the format "flt.<type>.<filter_name>", returns a list
#' of UI components that apply to the given filter type.

addFilterUI   <- function(flt_name = "flt.integer.specimen_id"){
  deets   <- str_match(flt_name,"^flt\\.(.+)\\.(.+)$")
  input_id<- flt_name
  type_in <- deets[,2]
  col_nm  <- deets[,3]
  if(type_in == "character"){
    logic_input   <- paste0(flt_name,"_logic")
    return(
      fluidRow(
        column(4,h4(col_nm)),
        column(3,selectInput(inputId = logic_input,label = "",multiple = FALSE,
                             choices=c("Contains","Exact"),selected = "Contains")),
        column(5,textInput(inputId = flt_name,label = "",value = ""))
      )
    )
  }else if(type_in == "integer"){
    min_input     <- paste0(flt_name,"_min")
    max_input     <- paste0(flt_name,"_max")
    val_input     <- paste0(flt_name,"_val")
    type_input    <- paste0(flt_name,"_inputType")
    return(
      fluidRow(
        column(4,h4(col_nm)),
        column(3,selectInput(inputId = type_input,label = "",multiple = FALSE,
                  choices = c("Equals","Greater than","Less than"),selected = "Equals")),
        column(5,numericInput(inputId = val_input,label = "",value = 0))
      )
    )
  }
}