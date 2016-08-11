library(shiny)
library(V8)
library(shinyjs)
library(shinyBS)


shinyUI(fluidPage(
  
  shinyjs::useShinyjs(),
  
  fluidRow(
    singleton(tags$head(tags$script(src="https://developer.bsvecosystem.net/sdk/api/BSVE.API.js"))),
    singleton(tags$head(tags$script(src="bsve.js")))
  ),
  
  fluidRow(
      tabsetPanel(
        tabPanel("Home",
                 column(8, offset = 2, align="center",
                            tags$h3("Welcome"),
                            
                            shinyjs::hidden(
                              div(id = "user_details",
                                  tags$br(),
                                  textOutput("user_info"),
                                  tags$br()
                                  )#end of div
                              ),#end of hidden
                            
                            tags$br(),
                            
                            fluidRow( title = "Description",
                              p("This app shows you how you can use the ", 
                                a("BSVE.API.js", href = "https://developer.bsvecosystem.net/sdk/api/BSVE.API.js"), 
                                " and the BSVE Data API"),
                              
                              p("The BSVE.API.js can be used to include the ", 
                                a("Dossier Bar", href = "http://developer.bsvecosystem.net/wp/tutorials/adding-the-dossier-bar/"), 
                                " and the ", 
                                a("Search bar.", href = "http://developer.bsvecosystem.net/wp/tutorials/adding-the-search-bar/")),
                              
                              tags$br(),tags$br()
                            ),
                        
                            # Data Sources
                            fluidRow( title = "Data Sources",
                                      column(width = 12,
                                             div(id = "data_sources",
                                                 fluidRow(title = "Data Sources Button",
                                                          p("You can view all the various data sources available in the Data API by clicking on the button below."),
                                                          tags$br(),
                                                          tags$head(tags$script(HTML(' Shiny.addCustomMessageHandler("jsCode",
                                                                                     function(message) {
                                                                                     console.log(message)
                                                                                     eval(message.code);
                                                                                     });')
                                                                                )
                                                          ),
                                                          actionButton(inputId = "data_sources_btn",
                                                                       label = "Data Sources")
                                                          ),
                                                 tags$br(), tags$br(),
                                                 fluidRow(title ="Data Sources Table",
                                                          dataTableOutput("dataSourceTable")
                                                          ),
                                                 # tags$br(), tags$br(),
                                                 # fluidRow(title ="Data Sources Table",
                                                 #          htmlOutput(outputId = "exception"),
                                                 #          dataTableOutput("source_table")
                                                 # ),
                                                 tags$br(), tags$br()
                                             )#end of div
                                      )#end of column
                            )
                        )#end of column
                 ),
        
        tabPanel("BSVE Data API",
                    #Side Panel
                    column(width = 4,
                        wellPanel(
                        
                        tags$br(),
                      
                        # Data Source Types
                        fluidRow( title = "Data Source Types",
                                  column(width = 12, 
                                      a(id = "toggle_data_source_types", "Data Source Types", href = "#"),
                                      bsTooltip(id = "toggle_data_source_types", title = "Click Me", placement = "right"),
                                      shinyjs::hidden(
                                        div(id = "data_source_types",
                                            tags$br(),
                                            selectInput("data_source_type", label = "Data Source Types List", choices = c()) 
                                            )#end of div
                                      )#end of hidden
                                  )#end of column
                        ),
                        
                        tags$br(),
                        
                        # SODA Data Source
                        conditionalPanel(condition = "input.data_source_type == 'SODA'", 
                                         fluidRow( title = "SODA Data Source",
                                                   column(width = 12, 
                                                       a(id = "toggle_soda_sources", "SODA Data Source", href = "#"),
                                                       bsTooltip(id = "toggle_soda_sources", title = "Click Me", placement = "right"),
                                                       shinyjs::hidden(
                                                         div(id = "soda_sources",
                                                             tags$br(),
                                                             selectInput("soda_source", label = "Select a SODA Source", choices = c()),
                                                             
                                                             conditionalPanel(condition = "!(input.soda_source == 'MMWR Weekly influenza and pneumonia deaths' ||
                                                                                           input.soda_source == 'Human Development Index' ||
                                                                                           input.soda_source == 'World Development Indicators')", 
                                                                              fluidRow( title = "SODA Choices",
                                                                                        column(7, radioButtons(inputId = "soda_choice", label = "Select and Submit", 
                                                                                                               choices = c("View Disease List" = "disease_list", 
                                                                                                                           "View Raw Data" = "raw_data"),
                                                                                                               selected = "disease_list" )
                                                                                        ),
                                                                                        column(5, tags$br(),
                                                                                               tags$head(tags$script(HTML(' Shiny.addCustomMessageHandler("jsCode",
                                                                                                                          function(message) {
                                                                                                                          console.log(message)
                                                                                                                          eval(message.code);
                                                                                                                          });')
                                                                                                    )
                                                                                               ),
                                                                                               actionButton(inputId = "soda_choice_btn",
                                                                                                            label = "Submit")
                                                                                               )
                                                                                        )
                                                                              )#end of conditional panel
                                                              )#end of div
                                                        )#end of hidden
                                                   )#end of column
                                          )#end of fluidRow
                        ),
    
                        
                        # RSS Data Source
                        conditionalPanel(condition = "input.data_source_type == 'RSS'", 
                                         fluidRow( title = "RSS Data Source",
                                                   column(width = 12,
                                                       a(id = "toggle_rss_sources", "RSS Data Source", href = "#"),
                                                       bsTooltip(id = "toggle_rss_sources", title = "Click Me", placement = "right"),
                                                       shinyjs::hidden(
                                                         div(id = "rss_sources",
                                                             tags$br(),
                                                             selectInput("rss_source", label = "Select a RSS Source", choices = c()),
                                                             
                                                             fluidRow( title = "RSS Submit",
                                                                       column(4, offset = 4,
                                                                              tags$head(tags$script(HTML(' Shiny.addCustomMessageHandler("jsCode",
                                                                                                         function(message) {
                                                                                                         console.log(message)
                                                                                                         eval(message.code);
                                                                                                         });')
                                                                                                    )
                                                                              ),
                                                                              actionButton(inputId = "rss_choice_btn",
                                                                                           label = "View Data")
                                                                              )
                                                                       )
                                                          )#end of div
                                                       )#end of hidden
                                                   )#end of column
                                         )#end of fluidRow
                        ),
                        
                        #Increses height of wellpanel
                        tags$br(),tags$br(),tags$br(),tags$br(),tags$br(),tags$br(),tags$br(),tags$br(),tags$br()  
                        
                        )#end of wellPanel
                      ),#end of column - sidePanel
                    
                    #Main Panel
                    mainPanel( width = 8,
                      #Display sources details as a table.
                      # conditionalPanel(condition = "input.data_source_type == 'SODA' && input.soda_choice == 'disease_list'",
                      #                  fluidRow(
                      #                    column(8, offset = 2, align = "center",
                      #                           h3(htmlOutput("display_disease_list"))
                      #                    )
                      #                  )
                      # ),
                      #Display Disease List within a text output.
                      conditionalPanel(condition = "input.data_source_type == 'SODA' && input.soda_choice == 'disease_list'",
                                       fluidRow(
                                         column(8, offset = 2, align = "center",
                                                h3(htmlOutput("display_disease_list"))
                                         )
                                       )
                      ),
                      #Display Raw Data as a Table
                      conditionalPanel(condition = "input.data_source_type == 'SODA' && input.soda_choice == 'raw_data'",
                                       fluidRow(
                                         column(4, offset = 8, align = "right",
                                                shinyjs::hidden(
                                                  div(id = "download_soda_csv",
                                                      downloadButton("download_soda_data", label = "Download")
                                                  )
                                                )
                                         )
                                       ),
                                       fluidRow(
                                         column(12, align = "center",
                                                tags$br(),
                                                dataTableOutput("soda_source_data")
                                         )
                                       )
                      ),
                      #Display Raw Data as a Table
                      conditionalPanel(condition = "input.data_source_type == 'RSS'",
                                       fluidRow(
                                         column(4, offset = 8, align = "right",
                                                shinyjs::hidden(
                                                  div(id = "download_rss_csv",
                                                      downloadButton("download_rss_data", label = "Download")
                                                  )
                                                )
                                         )
                                       ),
                                       fluidRow(
                                         column(12, align = "center",
                                                tags$br(),
                                                dataTableOutput("rss_source_data")
                                         )
                                       )
                      )
                    )#end of column
                )#end of tabpanel
      )#End of tabsetpanel
  )#end of fluidrow
))
