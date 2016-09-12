# RShiny-BSVE
RShiny App that shows how you can use BSVE Data API and BSVE.API.js

# BSVE Data API
## Intro
#### Prerequisites
You will need the following packages,

	* 'httr'

>Make sure to add them to your `.config` file.

## How to use in R Shiny
#### Using Harbinger Authentication Ticket
This allows you to connect to the BSVE Data API with User Credentials. You will need to pass the Authentication Ticket received from the BSVE.

```
query_url <- "https://api.bsvecosystem.net/data/v2/sources/"
GET(query_url, add_headers("harbinger-auth-ticket" = ticket))
```

> Note: There are major changes in the BSVE Data API from v1 to v2. You might want to experiment the different endpoints first using a REST Client. More information can be found [here](http://developer.bsvecosystem.net/wp/tutorials/bsve-data-api/api-reference/)

#### Get data for a Data Source
use `data/v2/sources/{dataSource}/data/` to view all the data sources.

```
pull_data <- function(ticket, data_source) {

  #Query URL and GET Request
	query_url <- paste0("https://api.bsvecosystem.net/data/v2/sources/",data_source,"/data")
  query_response <- GET(query_url, add_headers("harbinger-auth-ticket" = ticket))

  #Checking if the Request was successful
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    query_content <- content(query_response)

    #Checking if there was an error in getting the data source
    if (!is.null(query_content$errors)) {
      errors_df <- do.call(rbind, query_content$errors)
      errors_df <- as.data.frame(errors_df)
      errors_df		#errors_df is a dataframe
    } else {
      query_result <- query_content$result

			#converting the list of lists to a dataframe
			test <- do.call(rbind, query_result)
			result_df <- as.data.frame(test)

			#Cleaning up data
			result_df[result_df == "NULL"] <- NA       #Replacing all NULL to NAs
			result_df$estimate[is.na(result_df$estimate)] <- 0        #Replacing all NAs to 0
			result_df <- as.data.frame(lapply(result_df, unlist))     #Unlisting all the columns to allow data frame operations

			return(result_df)
    }#end of if else - errors
  }#end of if else - success
}
```



# BSVE.API.js
## Intro

The BSVE.API.js can be found at this [link](https://developer.bsvecosystem.net/sdk/api/BSVE.API.js)
This javascript file allows you to receive or send information to the BSVE Ecosystem. Few of the functionalities are listed below,

	* Get User Information
	* Get User Authentication Ticket
	* Add Dossier Bar
	* Enable Federated Search
	* Enable communication between different apps
For a full list of what you can do refer [here](http://developer.bsvecosystem.net/wp/api-reference/)

To use this javascript file you would have to create your own javascript file say `bsve.js` that calls the `BSVE.init()` function. Place `bsve.js` in a folder called `www`. Following should be the file structure for your app
* RShiny-App
	* ui.R
	* server.R
	* .config
	* www
		* bsve.js

Your RShiny app you should have the following code in `ui.R`
```
  fluidRow(
    singleton(tags$head(tags$script(src="https://developer.bsvecosystem.net/sdk/api/BSVE.API.js")))
    singleton(tags$head(tags$script(src="bsve.js")))
  ),
```

To pass values from `bsve.js` to `server.R` you would have to write something like this,

bsve.js
```
Shiny.onInputChange('variable_in_R', local_variable);
```

server.R
```
observe({
    input$variable_in_R
    //YOUR CODE
})
```

## Harbinger Authentication Ticket
This will allow you to connect with the BSVE Data API using user authentication details.

The `bsve.js` should include the following,

```
BSVE.init(function()
{
	//Receive Authentication Ticket from BSVE.API.js
	var auth_ticket = BSVE.api.authTicket();
	Shiny.onInputChange('authTicket', auth_ticket);
});
```

The `server.R` should include the following,
```
shinyServer(function(input, output, session) {
  #auth ticket received from BSVE Client
  ticket <- ""
  
  ## Receive user auth ticket from bsve.js ##
  observe({
    if (is.null(input$authTicket)) {
      return()
    } else {
      #Auth Ticket received
      ticket <<- input$authTicket
    }
  })
```

The variable `ticket` can now be used throughout `server.R`
