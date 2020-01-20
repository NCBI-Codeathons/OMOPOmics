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
      downloadButton(outputId = "output_download_btn",label = "Save")
    ),
    mainPanel(
      dataTableOutput(outputId = "table_output")
    )
  )
))
