library(httr)
library(jsonlite)
library(dplyr)
library(yaml)

#Load the bsve_sha1.R which contains the function to generate the tokens
source(paste(normalizePath(getwd()), "BSVE Data API", "bsve_sha1.R", sep=.Platform$file.sep), local = FALSE)

#loading configuration from a yaml file
config = yaml.load_file(paste(normalizePath(getwd()), "BSVE Data API", "config.yaml", sep=.Platform$file.sep))

#Generate the token
token <- bsve_sha1(config$api_key, config$secret_key, config$email)


#' data_sources_list
#'
#'@return DataFrame consisting of all data sources with the columns name, type, category and description.
#'@export
#'
#' History
#'    Created on 08/02/2016
#'
data_sources_list <- function()
{
  query_url <- "https://api.bsvecosystem.net/data/v2/sources/"
  query_response <- GET(query_url, add_headers("harbinger-authentication" = token))
  
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    query_content <- content(query_response)
    query_result <- query_content$result
    
    # Converting query_Result into a dataframe
    result_df <- do.call(rbind, query_result)
    result_df <- as.data.frame(result_df)
    
    #Trimming the data frame
    result_df <-
      rbind(select(
        result_df,
        contains("name"),
        contains("type"),
        contains("category"),
        contains("description")
      ))
    
    #Cleaning up data - changing all "NULL" values to NA and then unlisting all the columns in dataframe
    #Required if you need to be able to sort or search on the data frame
    result_df[result_df == "NULL"] <- NA
    result_df <- as.data.frame(lapply(result_df, unlist))
    
    return(result_df)
  }
}


#' data_sources_type_list
#'
#'@return List of all data source types available
#'@export
#'
#' History
#'    Created on 08/02/2016
#'
data_sources_type_list <- function()
{
  query_url <- "https://api.bsvecosystem.net/data/v2/sources/"
  query_response <-
    GET(query_url, add_headers("harbinger-authentication" = token))
  
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    query_content <- content(query_response)
    query_result <- query_content$result
    
    data_sources_list <- c()
    for (element in query_result)
    {
      data_sources_list <- c(data_sources_list, element$type)
    }
    data_sources_list <- unique(data_sources_list)
    
    return(data_sources_list)
  }
}


#' data_sources_type
#'
#'@param token - Harbinger Authentication Token
#'@param data_type - Data Source Type
#'
#'@return List of all data sources for the given type
#'@export
#'
#' History
#'    Created on 08/02/2016
#'
data_sources_type <- function(data_type)
{
  query_url <- "https://api.bsvecosystem.net/data/v2/sources"
  #data_type <- "soda"
  query_response <-
    GET(
      query_url,
      add_headers("harbinger-authentication" = token),
      query = list(`$filter` = paste0("type eq ", data_type))
    )
  
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    data <- content(query_response)
    data_result <- data$result
    
    data_sources <- c()
    i <- 0
    
    while (i < length(data_result))
    {
      i <- i + 1
      data_sources <- c(data_sources, data_result[[i]]$name)
    }
    
    return(data_sources)
  }
}


#' soda_source_diseases_list
#'
#'@param data_source - Name of Data Source to fetch disease list for
#'
#'@return List consisting of disease names in the given Data Source
#'@export
#'
#' History
#'    Created on 08/02/2016
#'
soda_source_diseases_list <- function(data_source)
{
  result_df <- data.frame()
  result_df = data_source_raw_df(data_source)
  
  if(nrow(result_df) == 0)
  {
    return()
  } else {
    disease_names_list <- c()
    
    # Returns the diseases in this file.
    dnames <- grep("*_current_week$", names(result_df), value = TRUE)
    for(dname in dnames)
    {
      pos = regexpr("*_current_week$", dname)
      disease_names_list <- c(disease_names_list, substr(dname,1,pos-1) )
    }
    disease_names_list <- gsub("_", " ", disease_names_list, fixed = T)
    disease_names_list <- gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", disease_names_list, perl=TRUE)
    
    return(disease_names_list)
  }
}


#' soda_source_formatted_df
#'
#'@param data_source - Name of Data Source to fetch data for
#'
#'@return DataFrame consisting of following fields, (disease columns, MMWR Year, MMWR Week, Reporting Area)
#'@export
#'
#' History
#'    Created on 08/05/2016
#'
soda_source_formatted_df <- function(data_source)
{
  result_df <- data.frame()
  result_df <- data_source_raw_df(data_source)
  
  if(nrow(result_df) == 0)
  {
    return()
  } else {
    # Returns the diseases in this file.
    dnames <- grep("*_current_week$", names(result_df), value = TRUE)
    
    #Modify the df to contain columns "Disease Current Week", MMWR Year, MMWR Week and Reporting Area
    nndss <- rbind( select(result_df, one_of(dnames), contains("MMWR"), contains("Reporting"), -contains("flag")) )
    
    #Try to clean up the dataframe to allow dataframe operations (sort, filter)
    nndss <- cleanup_data_frame(nndss)
    
    return(nndss)
  }
}


#' data_source_raw_df
#'
#'@param data_source - Name of Data Source to fetch data for
#'
#'@return DataFrame consisting of all the fields
#'@export
#'
#' History
#'    Created on 08/02/2016
#'
data_source_raw_df <- function(data_source)
{
  #Query URL and GET Request
  query_url <-
    paste0("https://api.bsvecosystem.net/data/v2/sources/",
           gsub(" ", "%20", data_source),
           "/data")
  query_response <-
    GET(query_url,
        add_headers("harbinger-authentication" = token),
        timeout(300))
  
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    query_content <- content(query_response)
    
    if (!is.null(query_content$errors)) {
      errors_df <- do.call(rbind, query_content$errors)
      errors_df <- as.data.frame(errors_df)
      
      return(errors_df)
    } else {
      query_result <- query_content$result
      
      #Check if the data source type is SODA or RSS and generate the data frame accordingly.
      #If not, then return nothing.
      #NOTE - If you need to process another type of data source, add another else if condition
      if (check_data_source_type(data_source) == "SODA") {
        #Convert the result into a JSON and then to a dataframe
        dat <- toJSON(query_result)
        result_df <- fromJSON(dat)
        
        #Try to clean up the dataframe to allow dataframe operations (sort, filter)
        result_df <- cleanup_data_frame(result_df)
        
        return(result_df)
      } else if (check_data_source_type(data_source) == "RSS") {
        #Convert the result to a data frame
        test <- do.call(rbind, query_result)
        result_df <- as.data.frame(test)
        
        #Try to clean up the dataframe to allow dataframe operations (sort, filter)
        result_df <- cleanup_data_frame(result_df)
        
        return(result_df)
      } else {
        return()
      }
    }#end of else - errors
  }#end of else - success
}


#' check_data_source_type
#'
#'@param data_source - Name of Data Source to fetch data for
#'
#'@return Var with Data Source Type if found, null otherwise.
#'
#' History
#'    Created on 08/02/2016
#'
check_data_source_type <- function(data_source)
{
  query_url <- "https://api.bsvecosystem.net/data/v2/sources"
  query_response <-
    GET(
      query_url,
      add_headers("harbinger-authentication" = token),
      query = list(`$filter` = paste0("name eq '", data_source, "'"))
    )
  
  #If query request is successfull - process response, Else return null
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    query_content <- content(query_response)
    
    #If errors - return Null, Else return data source type
    if (!is.null(query_content$errors)) {
      return()
    } else {
      query_result <- query_content$result
      return(query_result[[1]]$type)
    }#end of if else - errors
  }#end of if else - success
}


#' cleanup_data_frame
#' 1. Converts all NULL strings into NA
#' 2. Unlist all columns in data frame
#' 
#'@param df - Data Frame to clean up.
#'
#'@return DataFrame returns either a cleaned up dataframe or the same data frame as passed
#'
#' History
#'    Created on 08/02/2016
#'
cleanup_data_frame <- function(df)
{
  df <- tryCatch({
    df[df == "NULL"] <- NA
    as.data.frame(lapply(df, unlist))
  }, error = function(err) {
    return(df)
  })
  
  return(df)
}