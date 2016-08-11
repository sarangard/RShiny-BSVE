# RShiny-BSVE
RShiny App that shows how you can use BSVE Data API and BSVE.API.js

# BSVE Data API
## Intro
#### Prerequisites
You will need the following packages, 

	* 'httr'
	* 'yaml'

Make sure to add them to your `.config` file.

## How to use in R Shiny
#### Using API Access Keys
This allows you to connect to the BSVE Data API with a developer account.
You will need to get the API and Secret Keys from the developer site  under My Account -> Manage API Credentials and replace them below. Further details can be found [here](http://developer.bsvecosystem.net/wp/tutorials/api-documentation/)

Fill the following information in the `config.yaml` as follows,
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

query_url <- ""
GET(query_url, add_headers("harbinger-authentication" = token))
```


#### Using Harbinger Authentication Ticket
This allows you to connect to the BSVE Data API with User Credentials.
You will need to pass the Authentication Ticket received from the BSVE.

```
query_url <- ""
GET(query_url, add_headers("harbinger-auth-ticket" = ticket))
```

#### Listing Data Sources
It is very importatnt to note the major change in 
	* old api
	* new api

#### Listing Data Source Types
	* old api
	* new api

#### Data Sources
	* old api
	* new api
	

	
# BSVE.API.js
## Intro




To pass values from `your-js-file.js` to `server.R` you would have to write something like this,

your-js-file.js
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

The `your-js-file.js` should include the following,
```
BSVE.init(function()
{
	//Receive User Details from BSVE.API.js
	var user_details = BSVE.api.userData();
	Shiny.onInputChange('user_details', userData);
});
````

## Harbinger Authentication Ticket
This will allow you to connect with the BSVE Data API using user authentication details.

The `your-js-file.js` should include the following,
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

The `your-js-file.js` should include the following,
```
BSVE.init(function()
{
    /*
     * Dossier Control
     */
    BSVE.ui.dossierbar.create(function(status)
  	{
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

The `your-js-file.js` should include the following,
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
    },true,true,true);

});
```
