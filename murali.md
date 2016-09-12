# BSVE Data Viewer - Application

The following example demonstrates how to perform data manipulation (CRUD operation) for a given data source.

### Dependencies
The following dependencies are used in this application

Client


	* BSVE.API.js
	* jQuery
	* AngularJS
	* jgGrid

Server


	* Sprint MVC
	* Json/Gson lib	
  

### Code Walkthrough ###

##### 1. Connecting to the AWB
Before any communication with the AWB can be made through the BSVE API, the `BSVE.init(initApp)` method must be called. Any code inside of the initApp function will be executed once the AWB has responded to the app and triggered the callback.

```
// BSVE SDK API init
BSVE.init(function() {
	$scope.authTicket = BSVE.api.authTicket();
	$scope.data.bsve.header[$scope.data.bsve['header-name']] = $scope.authTicket;
	$scope.data.bsve.userInfo = BSVE.api.userData();
});
```

##### 2. Find a data source along with passing authentication ticket in request header

The request header has been asigned to angular variable & used when request has been sent to server
```
$scope.data = {
		name : '',
		bsve : {
			// 'header-name' : 'harbinger-authentication',
			'header-name' : 'harbinger-auth-ticket',
			header : {
				// 'harbinger-authentication' : $scope.authTicket,
				'harbinger-auth-ticket' : $scope.authTicket
			},
			userInfo : {}
		.....
		}
}

$scope.findDataByDataSource = function() {
	console.log("BSVE auth ticket.... " + $scope.authTicket);

	$scope.data.search.loading = true;
	clearJqGrid();
	resetMessage();

	console.log("Selected Data Source : " + $scope.data.name);
	var url = 'bsve/data/' + $scope.data.name;

	$http.get(url, {
		headers : $scope.data.bsve.header
	}).success(function(response) {
		$scope.bsveDataResponse = response;
		buildJqGrid();		
		$scope.data.search.loading = false;
	}).error(function() {
		$scope.data.search.loading = false;
	});
};

```

##### Retrieve data source name along with authentication ticket in Server Side Code

```
private ResourceInfo buildResourceInfo(HttpServletRequest request) {
	ResourceInfo info = new ResourceInfo();
	info.setUrl("");
	if (null == request.getHeader("harbinger-authentication")
			|| request.getHeader("harbinger-authentication").trim().length() == 0) {
		info.setUserAuthTicket(request.getHeader("harbinger-auth-ticket"));
	} else {
		info.setUserAuthTicket(request.getHeader("harbinger-authentication"));
	}
	
	return info;
}
```

	* Authentication ticket retrieved from "harbinger-auth-ticket" header parameter from Http Request & value has been set into Resource Info DTO and transferred to service layer
	* From Service Layer, Data API Request has been invoked with retrieved data source name & auth ticket

##### 3. Viewing Data in jqGrid Table with dynamic data column & jqGrid UI Controls

Building jqGrig UI with dynamically created column model

```
$("#fieldRawDataList").jqGrid({
	url : 'data.json',
	datatype : 'local',
	colNames : $scope.data.grid.colNames,
	colModel : $scope.data.grid.colModel,
	rowNum : 10,
	rowList : [ 10, 20, 40, 80, 100 ],
	pager : '#fieldRawDataPager',
	autowidth : true,
	viewrecords : true,
	rownumbers : true,
	height : "100%",
	data : $scope.bsveDataResponse.result.data.result,

});
```

Defining pagination & Create, Update and Delete icon controls in tabel footer

```
$("#fieldRawDataList").jqGrid('navGrid', '#fieldRawDataPager', {}, // options
editOptions, addOptions, delOptions, {}
);
```

##### 4. Add a record

```
$.extend(
$.jgrid.edit,
{
	closeAfterEdit : true,
	closeAfterAdd : true,
	width : 'auto',
	ajaxEditOptions : {
		contentType : "application/json",
		beforeSend : function(jqXHR, settings) {
			jqXHR
					.setRequestHeader(
							$scope.data.bsve['header-name'],
							$scope.data.bsve.header[$scope.data.bsve['header-name']]);
		}
	},
	serializeEditData : function(data) {
		delete data.oper;
		return JSON.stringify(data);
	}
});
							
var addOptions = {
	mtype : "POST",
	onclickSubmit : function(params, postdata) {
		params.url = 'bsve/data/' + $scope.data.name;
	},
	afterComplete : function(data) {
		if (data.status == 200) {
			if (data.responseJSON.status == 1) {
				$scope.reloadData();
				setInfo('New record added successfully.');

			} else {
				setError(data.responseJSON.message);
			}
		} else {
			setError('Failed to add record.');
		}
	}
};
```		
	* On click on submit button in add record model panel, it trigger "onclickSubmit" method to send request to server with the data. The new record has been converted into json format.
	* Server retrives the data into Gson Document
	* The document will be converted into json arrays before posting to Data API request
```
@RequestMapping(value = "/data/{dataSource}", method = RequestMethod.POST, consumes = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody ServiceResponse<String> addData(HttpServletRequest request,
			@PathVariable(value = "dataSource") String dataSource, @RequestBody Document document)
			throws JsonParseException, JsonMappingException, UnsupportedEncodingException, IOException, JSONException {

		LOGGER.info("Add new record...");
		return bsveDataService.addRecord(buildResourceInfo(request), dataSource, document);
	}
```

Service Layer

```
@Override
public ServiceResponse<String> addRecord(ResourceInfo resourceInfo, final String datasource, Document record)
		throws JsonParseException, JsonMappingException, IOException, JSONException {
	String path = String.format(DATA_SOURCE_DATA_PATH, URLEncoder.encode(datasource, "UTF-8"));

	ServiceResponse<String> response = new ServiceResponse<String>();
	Map<String, String> headers = getHeader(resourceInfo);
	headers.put("Content-Type", MediaType.APPLICATION_JSON_VALUE);
	headers.put("Accept", MediaType.APPLICATION_JSON_VALUE);
	JSONArray jsonArray = new JSONArray();
	JSONObject json = new JSONObject(record.toJson());
	json.remove("id");
	jsonArray.put(json);
	String data = BsveHttpClient.performPost(getUrl(path), headers, jsonArray.toString());

	Data result = new ObjectMapper().readValue(data, Data.class);
	response.setStatus(result.getStatus());
	response.addMessage(handleError(result));

	return response;
}
```

##### 5. Update a record

```
$.extend(
$.jgrid.edit,
{
	closeAfterEdit : true,
	closeAfterAdd : true,
	width : 'auto',
	ajaxEditOptions : {
		contentType : "application/json",
		beforeSend : function(jqXHR, settings) {
			jqXHR
					.setRequestHeader(
							$scope.data.bsve['header-name'],
							$scope.data.bsve.header[$scope.data.bsve['header-name']]);
		}
	},
	serializeEditData : function(data) {
		delete data.oper;
		return JSON.stringify(data);
	}
});
							

var editOptions = {
mtype : 'PUT',
onclickSubmit : function(params, postdata) {
	params.url = 'bsve/data/' + $scope.data.name;
},
afterComplete : function(data) {
	if (data.status == 200) {
		if (data.responseJSON.status == 1) {
			$scope.reloadData();
			setInfo('Record has been updated successfully.');

		} else {
			setError(data.responseJSON.message);
		}
	} else {
		setError('Failed to updated record.');
	}
}
};
```		

	* On click on submit button in update record model panel, it trigger "onclickSubmit" method to send request to server with the data. The updated record has been converted into json format.
	* Server retrives the data into Gson Document
	* Invoke Data API request to update the data

```
@RequestMapping(value = "/data/{dataSource}", method = RequestMethod.PUT, consumes = MediaType.APPLICATION_JSON_VALUE)
public @ResponseBody ServiceResponse<String> updateData(HttpServletRequest request,
		@PathVariable(value = "dataSource") String dataSource, @RequestBody Document document)
		throws JsonParseException, JsonMappingException, UnsupportedEncodingException, IOException {

	LOGGER.info("Update selected record...");
	return bsveDataService.updateRecord(buildResourceInfo(request), dataSource, document);
}

```

Service Layer

```
@Override
public ServiceResponse<String> updateRecord(ResourceInfo resourceInfo, final String datasource, Document record)
		throws JsonParseException, JsonMappingException, IOException {
	String path = String.format(DATA_SOURCE_DATA_UPDATE, URLEncoder.encode(datasource, "UTF-8"), record.get("id"));

	ServiceResponse<String> response = new ServiceResponse<String>();
	Map<String, String> headers = getHeader(resourceInfo);
	headers.put("Content-Type", MediaType.APPLICATION_JSON_VALUE);
	headers.put("Accept", MediaType.APPLICATION_JSON_VALUE);

	String data = BsveHttpClient.performPut(getUrl(path), headers, record.toJson());

	LOGGER.info(data);

	Data result = new ObjectMapper().readValue(data, Data.class);
	response.setStatus(result.getStatus());
	response.addMessage(handleError(result));

	return response;
}
```
##### 6. Delete a record

```
$.extend(
$.jgrid.del,
{
	mtype : 'DELETE',
	ajaxDelOptions : {
		contentType : "application/json",
		beforeSend : function(jqXHR, settings) {
			jqXHR
					.setRequestHeader(
							$scope.data.bsve['header-name'],
							$scope.data.bsve.header[$scope.data.bsve['header-name']]);
		}
	},
	serializeDelData : function(data) {
		delete data.oper;
		return JSON.stringify(data);
	}
});
							

var delOptions = {
onclickSubmit : function(params, postdata) {
	params.url = 'bsve/data/' + $scope.data.name;
},
afterComplete : function(data) {
	if (data.status == 200) {
		if (data.responseJSON.status == 1) {
			$scope.reloadData();
			setInfo('Record has been deleted successfully.');
		} else {
			setError(data.responseJSON.message);
		}
	} else {
		setError('Failed to delete record.');
	}
}
};
```		

	* On click on submit button in delete record model panel, it trigger "onclickSubmit" method to send request to server with the data. 
	* Invoke Data API request to delete a data

```
@RequestMapping(value = "/data/{dataSource}", method = RequestMethod.PUT, consumes = MediaType.APPLICATION_JSON_VALUE)
	public @ResponseBody ServiceResponse<String> updateData(HttpServletRequest request,
			@PathVariable(value = "dataSource") String dataSource, @RequestBody Document document)
			throws JsonParseException, JsonMappingException, UnsupportedEncodingException, IOException {

		LOGGER.info("Update selected record...");
		return bsveDataService.updateRecord(buildResourceInfo(request), dataSource, document);
	}

```

Service Layer

```
@Override
public ServiceResponse<String> updateRecord(ResourceInfo resourceInfo, final String datasource, Document record)
		throws JsonParseException, JsonMappingException, IOException {
	String path = String.format(DATA_SOURCE_DATA_UPDATE, URLEncoder.encode(datasource, "UTF-8"), record.get("id"));

	ServiceResponse<String> response = new ServiceResponse<String>();
	Map<String, String> headers = getHeader(resourceInfo);
	headers.put("Content-Type", MediaType.APPLICATION_JSON_VALUE);
	headers.put("Accept", MediaType.APPLICATION_JSON_VALUE);

	String data = BsveHttpClient.performPut(getUrl(path), headers, record.toJson());

	LOGGER.info(data);

	Data result = new ObjectMapper().readValue(data, Data.class);
	response.setStatus(result.getStatus());
	response.addMessage(handleError(result));

	return response;
}
```
