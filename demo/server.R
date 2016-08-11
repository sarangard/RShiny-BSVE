library(shiny)

#Loading source file containing functions for retrieving data from Data_API
source(paste(normalizePath(getwd()), "BSVE Data API", "new_data_api.R", sep=.Platform$file.sep), local = FALSE)


# Data Sources List - Populated just once
data_sources_hidden <- TRUE
data_sources <- data.frame()

# Data Sources List - Populated just once
data_source_types_hidden <- TRUE
data_source_types <- list()

# SODA Sources List - Populated just once
soda_sources_hidden <- TRUE
soda_sources <- list()

# Twitter Sources List - Populated just once
twitter_sources_hidden <- TRUE
twitter_sources <- list()

# RSS Sources List - Populated just once
rss_sources_hidden <- TRUE
rss_sources <- list()

#SODA Data Source disease list and raw data
disease_list <- list()
soda_df <- data.frame()

# Javascript code - To disable a button
disableActionButton <- function(id,session) {
  session$sendCustomMessage(type="jsCode",
                            list(code= paste("$('#",id,"').prop('disabled',true)"
                                             ,sep="")))
}

# Javascript code - To enable a button
enableActionButton <- function(id,session) {
  session$sendCustomMessage(type="jsCode",
                            list(code= paste("$('#",id,"').prop('disabled',false)"
                                             ,sep="")))
}

shinyServer(function(input, output, session) {
  
  ## Receive username from bsve.js and display on screen ##
  observe({
    if (is.null(input$user_name)) {
      return()
    } else {
      output$user_info <- renderText({
        paste0("User Name is ", input$user_name, "\n")
      })
      
      shinyjs::show(id="user_details")
    }
  })

  ## Receive authentication ticket from bsve.js ##
  observe({
    if (is.null(input$authTicket)) {
      return()
    } else {
      #Send the Auth Ticket to new_data_api.R
    }
  })
  
  ## RSS - When Submit Button is clicked ##
  observeEvent(input$data_sources_btn, {
    #Disable Submit Button
    disableActionButton("data_sources_btn", session)
    
    #progress bar
    withProgress(value = 0.2, message = "Getting a summary of all Data Sources", {
      data_sources <- data.frame()
      data_sources <- data_sources_list()
      setProgress(value = 0.9, message = "Updating Main Panel")
      Sys.sleep(2)

    #   output$dataSourceTable <- DT::renderDataTable({ datatable(data_sources, 
    #                                                            options = list(pageLength = 25, 
    #                                                                           scrollX = TRUE,
    #                                                                           scrollY = "300px", 
    #                                                                           scrollCollapse = TRUE,
    #                                                                           target = "cell"),
    #                                                            selection = 'none', 
    #                                                            class = 'cell-border strip hover'
    #                                                            ) %>% formatStyle(1, cursor = 'pointer')
    #                                               })
      
      output$dataSourceTable <- renderDataTable(data_sources, options = list(pageLength = 25, 
                                                                             scrollX = TRUE,
                                                                             scrollY = "300px", 
                                                                             scrollCollapse = TRUE,
                                                                             target = "cell")
                                                  )
      
    })#end of withProgress
    
    #Enable Submit Button
    enableActionButton("data_sources_btn", session)
  })
  
  
  ## Loads list of all Data Sources ##
  shinyjs::onclick("toggle_data_sources", {
    if(data_sources_hidden)
    {
      #Check if the data_sources have already been populated. If not populate them.
      if(nrow(data_sources) == 0)
      {
        withProgress(value = 0.2, message = "Getting the list of data sources", {
          
          setProgress(value = 0.9, message = "Updating View")
          Sys.sleep(2)
          #TO DO
          shinyjs::show(id="data_sources") 
        })
      } else {
        #TO DO
        shinyjs::show(id="data_sources") 
      }
      
      data_sources_hidden <- FALSE
    } else {
      shinyjs::hide(id="data_sources")
      data_sources_hidden <- TRUE
    }#End of if-else
  })
  
  ## EventListener for click on Data Sources List table ##
  ## Tried to get the data for the selected data source and displays it on screen ##
  # observeEvent(input$dataSourceTable_cell_clicked, {
  #   info = input$dataSourceTable_cell_clicked    
  # 
  #   if (is.null(info$value)) {
  #     return()
  #   } else {
  #     withProgress(value = 0.2, message = paste0("Getting the raw data for selected ",info$value) , {
  #       data_source_df <- as.data.frame(data_source_raw_df(info$value))
  #       
  #       if(nrow(data_source_df) == 0) {
  #         output$exception <- renderUI({
  #           msg <- paste("You don't have access to the Data Source.")
  #           HTML(msg)
  #         })
  #       } else {
  #         output$source_table <- DT::renderDataTable({datatable(data_source_df, 
  #                                                               options = list(pageLength = 25, searching = FALSE,
  #                                                                              scrollX = TRUE, ordering = FALSE,
  #                                                                              scrollY = "300px", 
  #                                                                              scrollCollapse = TRUE))
  #         })#end of renderDataTable
  #       }
  #     })#end of withProgress
  #   }
  # })

  
  ## Loads list of all Data Source Types ##
  shinyjs::onclick("toggle_data_source_types", {
    if(data_source_types_hidden)
    {
      #Check if the data_sources have already been populated. If not populate them.
      if(length(data_source_types) == 0)
      {
        withProgress(value = 0.2, message = "Getting the list of data sources", {
          data_source_types <- as.list(data_sources_type_list())
          updateSelectInput(session, inputId = "data_source_type", label = "Data Source Types List",
                            choices = data_source_types )
          setProgress(value = 0.9, message = "Updating View")
          Sys.sleep(2)
          shinyjs::show(id="data_source_types") 
        })
      } else {
        updateSelectInput(session, inputId = "data_source_type", label = "Data Source Types List",
                          choices = data_source_types )
        shinyjs::show(id="data_source_types") 
      }
      
      data_source_types_hidden <- FALSE
    } else {
      #change selected choice to default
      updateSelectInput(session, inputId = "data_source_type", label = "Data Source Types List",
                        choices = data_source_types )
      #Hide all
      shinyjs::hide(id="data_source_types")  
      data_source_types_hidden <- TRUE
    }#End of if-else
 })
  
  ## Loads list of SODA Data Sources ##
  shinyjs::onclick("toggle_soda_sources", {
      if(soda_sources_hidden)
      {
        #Check if the soda_sources have already been populated. If not populate them.
        if(length(soda_sources) == 0)
        {
          withProgress(value = 0.2, message = "Getting the list of SODA data sources", {
            soda_sources <- as.list(data_sources_type("soda"))
            updateSelectInput(session, inputId = "soda_source", label = "Select a SODA Source",
                              choices = soda_sources )
            setProgress(value = 0.9, message = "Updating View")
            Sys.sleep(2)
            shinyjs::show(id="soda_sources") 
          })
        } else {
          updateSelectInput(session, inputId = "soda_source", label = "Select a SODA Source",
                            choices = soda_sources )
          shinyjs::show(id="soda_sources") 
        }
        
        soda_sources_hidden <- FALSE
      } else {
        shinyjs::hide(id="soda_sources")
        soda_sources_hidden <- TRUE
      }#End of if-else
    })

  
  ## Loads list of  RSS Data Sources ##
  shinyjs::onclick("toggle_rss_sources", {
    if(rss_sources_hidden)
    {
      #Check if the rss_sources have already been populated. If not populate them.
      if(length(rss_sources) == 0)
      {
        withProgress(value = 0.2, message = "Getting the list of RSS data sources", {
          rss_sources <- as.list(data_sources_type("rss"))
          updateSelectInput(session, inputId = "rss_source", label = "Select a RSS Source",
                            choices = rss_sources )
          setProgress(value = 0.9, message = "Updating View")
          Sys.sleep(2)
          shinyjs::show(id="rss_sources") 
        })
      } else {
        updateSelectInput(session, inputId = "rss_source", label = "Select a RSS Source",
                          choices = rss_sources )
        shinyjs::show(id="rss_sources") 
      }
      
      rss_sources_hidden <- FALSE
    } else {
      shinyjs::hide(id="rss_sources")
      rss_sources_hidden <- TRUE
    }#End of if-else
  })
  

  ## SODA - When Submit Button is clicked ##
  observeEvent(input$soda_choice_btn, {
      #Disable Submit Button
      disableActionButton("soda_choice_btn", session)
    
      if(input$soda_choice == "disease_list") {
        #progress bar
        withProgress(value = 0.2, message = "Getting the list of diseases from the selected SODA Data Source", {
            disease_list <- as.list(soda_source_diseases_list(input$soda_source))
            setProgress(value = 0.9, message = "Updating Main Panel")
            Sys.sleep(2)
            output$display_disease_list <- renderUI({
              header <- paste("Disease List", "<br/>", "<br/>", "<br/>")
              disease_str <- paste(disease_list, collapse = "<br/>")
              HTML(paste0(header, disease_str))
            })
        })
      } else if(input$soda_choice == "raw_data") {
        #Progress bar
        withProgress(value = 0.2, message = "Getting raw data for the selected SODA Data Source", {
            soda_df <- soda_source_formatted_df(input$soda_source)
            setProgress(value = 0.9, message = "Updating Main Panel")
            Sys.sleep(2)
            output$soda_source_data <- renderDataTable(soda_df, options = list(scrollX = TRUE, 
                                                                               scrollY = "300px",
                                                                               scrollCollapse = TRUE))
            shinyjs::show(id="download_soda_csv")
        })
        
      }
    
    #Enable Submit Button
    enableActionButton("soda_choice_btn", session)
  })
  
  ## SODA - To clear main panel when another input is selected ##
  observe({
    x <- input$soda_source
    
    if(length(soda_sources) > 0)
    {
      if(x %in% soda_sources)
      {
        soda_df <- data.frame()
        output$soda_source_data <- renderDataTable(soda_df)
        shinyjs::hide(id="download_soda_csv")
        output$display_disease_list <- renderUI(HTML(""))
      }
    }
  })

  
  ## SODA - Handler for Download CSV Button ##
  output$download_soda_data <- downloadHandler(
    # Set filename to "<selected_soda_source>.csv"
    filename = function(){
      paste(input$soda_source, "csv", sep = ".")
    },
    
    # Write content as a table with sep as ","
    content = function(file){
      write.table(soda_source_formatted_df(input$soda_source), file, sep = "," , row.names = FALSE)
    }
  )
  
  ## RSS - When Submit Button is clicked ##
  observeEvent(input$rss_choice_btn, {
    #Disable Submit Button
    disableActionButton("rss_choice_btn", session)
    
    #progress bar
    withProgress(value = 0.2, message = "Getting raw data for the selected RSS Data Source", {
      rss_df <- data.frame()
      rss_df <- data_source_raw_df(input$rss_source)
      setProgress(value = 0.9, message = "Updating Main Panel")
      Sys.sleep(2)
      output$rss_source_data <- renderDataTable(rss_df, options = list(pageLength = 10, scrollX = TRUE,
                                                                       scrollY = "300px", scrollCollapse = TRUE))
      shinyjs::show(id="download_rss_csv")
    })
    
    #Enable Submit Button
    enableActionButton("rss_choice_btn", session)
  })
  
  ## RSS - To clear main panel when another input is selected ##
  observe({
    x <- input$rss_source
    
    if(length(rss_sources) > 0)
    {
      if(x %in% rss_sources)
      {
        rss_df <- data.frame()
        output$rss_source_data <- renderDataTable(rss_df)
        shinyjs::hide(id="download_rss_csv")
      }
    }
  })

  ## RSS - Handler for Download Json Button ##
  output$download_rss_data <- downloadHandler(
    # Set filename to "<selected_rss_source>.csv"
    filename = function(){
      paste(input$rss_source, "csv", sep = ".")
    },
    
    # Write content as a table with sep as ","
    content = function(file){
      write.table(data_source_raw_df(input$rss_source), file, sep = "," , row.names = FALSE)
    }
  )
  
}) #End of ShinyServer
