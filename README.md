# RShiny-BSVE
RShiny App that shows how you can use BSVE Data API and BSVE.API.js

# BSVE Data API
## Intro
#### Prerequisites
You will need the following packages, 

	* 'httr'
	* 'yaml'

>Make sure to add them to your `.config` file.

## How to use in R Shiny
#### Using API Access Keys
This allows you to connect to the BSVE Data API with a developer account.
You will need to get the API and Secret Keys from the developer site  under My Account -> Manage API Credentials and replace them below. Further details can be found [here](http://developer.bsvecosystem.net/wp/tutorials/api-documentation/)


All the configuration information is store in a `config.yaml` file. Fill the following information in `config.yaml` as follows,
```
api_key : "API key"
secret_key : "SECRET key"
email : "your@email"
```

The `bsve_sha1` function creates the authentication header using the two keys and a valid email. 
```
token <- bsve_sha1(api_key, secret_key, email)
token
[1] "apikey=AK521cff65-9815-48bc-a97c-27fd3f4cd58d;timestamp=1457989545992;nonce=535514;signature=f6b90ed483b37..."

query_url <- "https://api.bsvecosystem.net/data/v2/sources/"
GET(query_url, add_headers("harbinger-authentication" = token))
```


#### Using Harbinger Authentication Ticket
This allows you to connect to the BSVE Data API with User Credentials. You will need to pass the Authentication Ticket received from the BSVE.

```
query_url <- "https://api.bsvecosystem.net/data/v2/sources/"
GET(query_url, add_headers("harbinger-auth-ticket" = ticket))
```

> Note: There are major changes in the BSVE Data API from v1 to v2. You might want to experiment the different endpoints first using a REST Client. More information can be found [here](http://developer.bsvecosystem.net/wp/tutorials/bsve-data-api/api-reference/)

#### Get all Data Sources
use `data/v2/sources` to view all the data sources.

```
  #Query URL and GET Request
  query_url <- "https://api.bsvecosystem.net/data/v2/sources/"
  query_response <- GET(query_url, add_headers("harbinger-authentication" = token))
  
  #Checking if the Request was successfull
  if (http_status(query_response)$category != "Success") {
    return()
  } else {
    query_content <- content(query_response)
    query_result <- query_content$result
    
    # Converting query_Result into a dataframe
    result_df <- do.call(rbind, query_result)
    result_df <- as.data.frame(result_df)
  }
```


#### Get data for a Data Source
use `data/v2/sources/{dataSource}/data/result` to view all the data sources.

```
  #Query URL and GET Request
  query_url <- paste0("https://api.bsvecosystem.net/data/v2/sources/", gsub(" ", "%20", data_source), "/data")
  query_response <- GET(query_url, add_headers("harbinger-authentication" = token), timeout(300))
  
  #Checking if the Request was successfull
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
      query_result	#query_result is a list of lists
    }
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

## User Deatils
This will allow you to get all the user information like

	* First Name
	* Last Name
	* Email
	* Role

The `bsve.js` should include the following,

```
BSVE.init(function()
{
	//Receive User Details from BSVE.API.js
	var user_details = BSVE.api.userData();
	Shiny.onInputChange('userData', user_details);
});
````

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
````

## Dossier Control
You can add the Dossier Bar in your R Shiny app. For further references refer [here](http://developer.bsvecosystem.net/wp/tutorials/adding-the-dossier-bar/)

The `bsve.js` should include the following,

```
BSVE.init(function()
{
    /*
     * Dossier Control
     */
    BSVE.ui.dossierbar.create(function(status)
  	{
  	    var dataTableHTML;
  	    // Updating "dataTableHTML" to hold dataTable from the browser window
  	    $('.tab-pane.active .shiny-datatable-output .dataTables_scroll').each(function(){ dataTableHTML = $(this)[0].outerHTML; });

  	    // Creating an "item" that can be tagged/stored in the dossier.
  	    // Required parameters for "item" are 
  	    //    dataSource, title, sourceDate, itemDetail[statusIconTpe, Description]
  		  var item = 
  		  {
    			dataSource: 'Data Source Name',
    			title: 'Item Title',
    			sourceDate : BSVE.api.dates.yymmdd(Date.now()),
    			itemDetail: 
    			{
    				statusIconType: 'Table',
    				Description: dataTableHTML
    			}
  		  };
  		
  		  //If there is a table in dataTableHTML, only then tag the item.
  		  if(dataTableHTML)
  		  {
        		// Tagging created item
        		BSVE.api.tagItem(item, status);
  		  }
  	});
});
```


## Federated Search
This allows you to perform a search within your app.

The `bsve.js` should include the following,

```
BSVE.init(function()
{
  /*
   * Federated Search
   */
  BSVE.api.search.submit(function(query)
    {
      if(query.term)
      {
          Shiny.onInputChange('search_query', query.term);
      }
    });
});
```
