shinyUI(fluidPage(
  titlePanel("OMOPOmics"),
  sidebarLayout(
    sidebarPanel(
      prettyToggle(inputId = "show_graph",value = TRUE,
                   label_on = "Hide table graph",
                   label_off = "Show table graph"),
      conditionalPanel(condition="input.show_graph==true",
                       plotOutput("table_graph")
      ),
      br(),
      selectInput(inputId="include_columns",label="Output columns:",multiple = TRUE,
                  choices=opt_include_cols,selected = opt_include_cols_def),
      selectInput(inputId="include_filters",label="Filter columns:",multiple = TRUE,
                  choices=opt_include_cols,selected = NULL),
      div(id="nextFilterUI"),
      fluidRow(
        column(4,textInput(inputId="output_filename",label = "Output file",value = "output_file")),
        column(3,selectInput(inputId= "output_sep_sel",label="Filetype",choices = c(CSV=",",TSV="\t"))),
        column(3,selectInput(inputId= "output_header" ,label="Header",choices=c("Yes","No")))
      ),
      fluidRow(
        column(4,downloadButton(outputId = "output_download_btn",label = "Save"))
      ),
      br(),
      prettyToggle(inputId = "show_query",value = FALSE,
                   label_on = "Hide Dbplyr query preview",
                   label_off = "Show Dbplyr query preview"),
      conditionalPanel(condition = "input.show_query==true",
        verbatimTextOutput(outputId = "sql_preview")
      )
    ),
    mainPanel(
      dataTableOutput(outputId = "table_output")
    )
  )
))

