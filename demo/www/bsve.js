BSVE.init(function()
{
    var dataTableHTML = '';

    //Receive User Data from BSVE.API.js
    var user = BSVE.api.userData();
    console.log(user);
    Shiny.onInputChange('user_name', user.userName);
    
    //Receive Authentication Ticket from BSVE.API.js
    var auth_ticket = BSVE.api.authTicket();
    console.log(auth_ticket);
    Shiny.onInputChange('authTicket', auth_ticket);


    /*
     * Dossier Bar
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
    
    
    /*
     * Communication between two different Apps
     */
    BSVE.api.exchange.receive(function(query)
    {
      if(query)
      {
          Shiny.onInputChange('exchange_query', query);
      }
    });

});