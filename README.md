# RShiny-BSVE
RShiny App that shows how you can use BSVE Data API and BSVE.API.js

# BSVE Data API
## Intro
#### Prerequisites
You will need the following package, 
	* 'httr'
	* 'yaml'

The `.config` file for the RShiny app will have to include the following,
	* 

## How to use in R Shiny
* Using API Access Keys
This allows you to connect to the BSVE Data API with a developer account.
You will need to get the API and Secret Keys from the developer site  under My Account -> Manage API Credentials and replace them below. Further details can be found [here](http://developer.bsvecosystem.net/wp/tutorials/api-documentation/)

Enter this information in the `config.yaml` in the following format.
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

* Using Harbinger Authentication Ticket
This allows you to connect to the BSVE Data API with User Credentials.
You will need to pass the Authentication Ticket received from the BSVE.

```
query_url <- ""
GET(query_url, add_headers("harbinger-auth-ticket" = ticket))
```

* Listing Data Sources 
	* old api
	* new api

* Listing Data Source Types
	* old api
	* new api

* Data Sources
	* old api
	* new api
	
	
# BSVE.API.js
## Intro
## Dossier Control
## Federated Search
