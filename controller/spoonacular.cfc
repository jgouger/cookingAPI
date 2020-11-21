component
{
    // setup constants
    this.mealTypes =
    [
        'Main Course', 'Side Dish', 'Dessert', 'Appetizer', 'Salad',
        'Bread', 'Breakfast', 'Soup', 'Beverage', 'Sauce', 'Marinade',
        'Fingerfood', 'Snack', 'Drink'
    ];

    this.cuisines = 
    [
        'African','American','British','Cajun','Caribbean',
        'Chinese','Eastern European','European','French','German',
        'Greek','Indian','Irish','Italian','Japanese','Jewish',
        'Korean','Latin American','Mediterranean','Mexican',
        'Middle Eastern','Nordic','Southern','Spanish',
        'Thai','Vietnamese'
    ];

    this.diets =
    [
        'Gluten Free', 'Ketogenic', 'Vegetarian', 'Lacto-Vegetarian', 'Ovo-Vegetarian', 'Vegan',
        'Pescetarian', 'Paleo', 'Primal', 'Whole30'
    ];

    function init()
    {
        return this;
    }

    /**
    * Returns the meal types constant
    * @returns {array} An array of the meal types
    */
    public array function getMealTypes()
    {
        return this.mealTypes;
    }

    /**
    * Returns the cusines constant
    * @return {array} An array of supported cuisine
    */
    public array function getCuisines()
    {
        return this.cuisines;
    }

    /**
    * Returns the diets constant
    * @returns {array} An array of supported diets
    */
    public array function getDiets()
    {
        return this.diets;
    }
    
    
    /**
    * Searches the API for a recipe based on the given options
    * @query {string} Query to search for. 
    * @type {string} Meal Type
    * @cuisine {string} Cuisine
    * @diet {string} Option diets
    * @returns {struct} JSON Object of results
    */
    remote struct function search(required string query, required string type, required string cuisine, string diet="") returnFormat="json"
    {
        var local = {};
        
        // validate that the search params are valid
        local.searchParams = cleanAndValidateInput(Arguments);
        local.searchParams['number'] = 9;

        local.httpParams =
        {
            "url": 'https://api.spoonacular.com/recipes/complexSearch',
            "method": 'get',
            "apiKey": getApiKey(),
            "queryParams": local.searchParams
        };

        return doHttp(httpParams);
    }

    /**
    * Gets the detailed inforamtion of a recipe
    * @recipeID {numeric} Recipe ID
    * @returns {struct} JSON Object of recipe detail information
    */
    remote struct function getDetails(required numeric recipeID) returnFormat="json"
    {
        var local = {};
        
        local.httpParams =
        {
            "url": 'https://api.spoonacular.com/recipes/#Arguments.recipeID#/information',
            "method": 'get',
            "apiKey": getApiKey()
        }

        return doHttp(local.httpParams)
    }

    /**
    * Validates the search form input for valid values
    * @returns {struct} validated search form input
    */
    private struct function cleanAndValidateInput(required struct searchParams)
    {
        var local = {};
        local.searchParams = Arguments.searchParams;
        
        // strip any HTML code from the Query
        local.searchParams['query'] = UrlEncodedFormat(ReReplaceNoCase(Trim(local.searchParams['query']), '<[^>]*>', '', 'all'));

        // validate the meal types
        if ( (local.searchParams['type'] == '' || ( local.searchParams['type'] != '' && ! ArrayFind(this.mealTypes, local.searchParams['type']) ) ) )
        {
            StructDelete(local.searchParams, 'type');
        }
        else
        {
            local.searchParams['type'] = urlEncodedFormat(local.searchParams['type']);
        }

        // validate the cuisine
        if ( (local.searchParams['cuisine'] == '' || ( local.searchParams['cuisine'] != '' && ! ArrayFind(this.mealTypes, local.searchParams['cuisine']) ) ) )
        {
            StructDelete(local.searchParams, 'cuisine');
        }
        else
        {
            local.searchParams['cuisine'] = urlEncodedFormat(local.searchParams['cuisine']);
        }

        // validate the diet restriction. Diets are a multi-select, treat accordingly
        if ( local.searchParams['cuisine'] == ''|| ( local.searchParams['cuisine'] != '' && ! ArrayFind(this.mealTypes, local.searchParams['cuisine']) ) ) 
        {
            StructDelete(local.searchParams, 'cuisine');
        }
        else
        {   
            local.searchParams['diet'] = ListToArray(local.searchParams['diet']);
            local.searchParams['validDiets'] = local.searchParams['diet'];

            for (local.d = 1; local.d <= ArrayLen(local.searchParams['diet']); local.d++)
            {
                if (! ArrayFind(this.diets, local.searchParams['diet'][local.d]) )
                {
                    ArrayDelete(local.searchParams['validDiets'], local.d);
                }
            }

            if (local.searchParams['validDiets'] == '')
            {
                StructDelete(local.searchParams, 'diet');
            }
            else
            {
                local.searchParams['diet'] = UrlEncodedFormat(local.searchParams['validDiets']);
            }
        }

        return local.searchParams;
    }

    /**
    * Shared function to connect to an external HTTP Service
    * @returns {struct} JSON object from the external HTTP Service
    */
    private struct function doHttp(required struct httpParams)
    {
        var local = {};
        local.retData = {};
        local.retData['results'] = {};
        local.retData['success'] = false;
        local.retData['msg'] = '';

        local.httpService = new http(method = Arguments.httpParams['method'], url = Arguments.httpParams['url']);
        local.httpService.addParam(name="apiKey", type="url", value="#Arguments.httpParams['apiKey']#");

        if (StructKeyExists(Arguments.httpParams, 'queryParams') )
        {
            for (local.qp in Arguments.httpParams['queryParams'])
            {
                local.httpService.addParam(name = LCase(local.qp), type = "url", value = Arguments.httpParams['queryParams'][local.qp]);
            }
        }

        local.httpResponse = local.httpService.send().getPrefix();

        if (local.httpResponse.responseHeader.status_Code != 200)
        {
            // http call failed. trap the error
            local.retData['msg'] = 'API Call Failed. Please try again';

            if (StructKeyExists(local.httpResponse, 'errorDetail'))
            {
                local.retData['debugMsg'] = local.httpResponse.errorDetail;
            }
        }
        else
        {
            local.retData['success'] = true;
            local.retData['results'] = DeserializeJSON(local.httpResponse.fileContent);
        }

        return local.retData;
    }

    /**
    * Attempts to get the ApiKey for this application
    * @returns {string} Api Key 
    */
    private string function getApiKey()
    {
        var local = {};
        local.apiKey = '';

        try
        {
            if (StructKeyExists(Server.system, 'environment') )
            {
                if (StructKeyExists(Server['system']['environment'], 'SPOONACULAR' ) )
                {
                    // We found the key!
                    local.apiKey = Server['system']['environment']['SPOONACULAR'];
                }
                else
                {
                    // Key Doesn't exist. Throw an error
                    throw('Please set a system environment variable called SPOONACULAR with your api key before using this application.');
                }
            }
            else
            {
                // The environment variable doesn't exist. Can we get the variable from Java?
                try
                {
                     local.systemObj = CreateObject('java', 'java.lang.system');
                     local.apiKey = local.systemObj.getEnv( javaCast("string", "SPOONACULAR") );
                }
                catch (any e)
                {
                    throw('ColdFusion was uanable to read the environment variables.');
                }
            }
        }
        catch (any e)
        {
            throw('The API Key was not found!');
        }
       
        return local.apiKey;
    }
}