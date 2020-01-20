shinyUI(fluidPage(
  titlePanel("OMOPOmics"),
  sidebarLayout(
    sidebarPanel(
      lapply(names(tabs),add_conditional_panel),
      fluidRow(
        column(4,textInput(inputId="output_filename",label = "Output file",value = "output_file")),
        column(3,selectInput(inputId= "output_sep_sel",label="Filetype",choices = c(CSV=",",TSV="\t"))),
        column(3,selectInput(inputId= "output_header" ,label="Header",choices=c("Yes","No")))
      ),
      fluidRow(
        column(4,downloadButton(outputId = "output_download_btn",label = "Save"))
      ),
      br(),
      prettyToggle(inputId = "show_query",label_on = "Hide Dbplyr query preview",label_off = "Show Dbplyr query preview",value = FALSE),
      conditionalPanel(condition = "input.show_query==true",
        verbatimTextOutput(outputId = "sql_preview")
      )
    ),
    mainPanel(
      dataTableOutput(outputId = "table_output")
    )
  )
))
