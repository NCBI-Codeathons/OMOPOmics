shinyUI(fluidPage(
  titlePanel("Database example"),
  tabsetPanel(
    tabPanel("Database",
      sidebarLayout(
        sidebarPanel(
          verbatimTextOutput("db_blurb"),
          #selectInput(inputId="db_mask",label = "Apply mask",multiple = FALSE,
          #            choices = opt_db_mask_select,selected = opt_db_mask_select_def),
          #selectInput(inputId="db_field_select",label = "Include columns",multiple = TRUE,
          #            choices = opt_db_field_select,selected = opt_db_field_select_def),
          #selectInput(inputId="db_filt_select",label = "Filter columns:",multiple = TRUE,
          #            choices = opt_db_filt_select, selected = opt_db_filt_select_def),
          #h2("Filter values"),
          #div(id="nextFilterUI"),
          #addFilterUI("flt.character.hla_values"),
          #addFilterUI("flt.integer.specimen_id")
          h2("Query"),
          textAreaInput(inputId="db_manual_query",label="",resize = "vertical",value = opt_db_manual_def)
          #actionButton(inputId="db_submit_manual_query",label="Submit")
        ),
        mainPanel(
          dataTableOutput("db_preview"),
          #br(),
          #dataTableOutput("flt_tbl")
        )
      )
    ),
    tabPanel("Input masks",
      sidebarLayout(
        sidebarPanel(
          selectInput(inputId="mask_select",label = "Mask",
                      choices = opt_mask_select,selected = opt_mask_select_def,multiple = FALSE),
          verbatimTextOutput("mask_blurb"),
          plotOutput("mask_network"),
          selectInput(inputId="mask_layout",label = "Layout",multiple = FALSE,
                      choices = opt_msk_layout,selected = opt_msk_layout_def)
        ),
        mainPanel(
          dataTableOutput("mask_table")
        )
      )
    ),
    tabPanel("Data model",
      sidebarLayout(
        sidebarPanel(
          selectInput(inputId="dm_select_table",label = "Select table",
                      choices = opt_dm_select_table,selected = opt_dm_select_table_def,multiple = FALSE),
          verbatimTextOutput("model_blurb"),
          plotOutput("model_network"),
          h5("Selected table and subjective tables and connections in black, dependent tables and connections in red."),
          selectInput(inputId="model_layout",label = "Layout",choices = opt_dm_layout,selected = opt_dm_layout_def,multiple = FALSE)
        ),
        mainPanel(
          dataTableOutput("model_table")
        )
      )
    ))
))