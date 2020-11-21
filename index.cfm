<cfscript>
    request.pageTitle = 'Random Recipe Generator';
    variables.mealTypes = request.controller.getMealTypes();
    variables.cuisines = request.controller.getCuisines();
    variables.diets = request.controller.getDiets();
</cfscript>

<cfoutput>
    <div class="card" id="search">
        <div class="card-header">
            Search for a Recipe
           <span class="float-right glyphicon glyphicon-chevron-down" aria-hidden="true"></span>
        </div>
        <div class="card-body">
            <form method="post">

                <div class="form-row">

                    <div class="form-group col-md-6">
                        <label for="query">Query:</label>
                        <input type="text" class="form-control" id="query" name="query" /> 
                    </div>

                    <div class="form-group col-md-6">
                        <label for="type" name="type">Meal Type:</label>
                        <select id="type" name="type" class="form-control">
                            <option value="">Select...</option>
                            <cfloop from="1" to="#ArrayLen(variables.mealTypes)#" index="variables.t">
                                <option value="#variables.mealTypes[variables.t]#">#variables.mealTypes[variables.t]#</option>
                            </cfloop>  
                        </select>
                    </div>

                </div>

                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label for="type">Cuisine:</label>
                        <select id="cuisine" name="cuisine" class="form-control">
                            <option value="">Select...</option>
                            <cfloop from="1" to="#ArrayLen(variables.cuisines)#" index="variables.c">
                                <option value="#variables.cuisines[variables.c]#">#variables.cuisines[variables.c]#</option>
                            </cfloop>  
                        </select>
                    </div>

                    <div class="form-group col-md-6">
                        <legend class="col-form-label col-sm-2 pt-0">Diet(s):</legend>
                        <cfloop from="1" to="#ArrayLen(variables.diets)#" index="variables.d">
                            
                            <cfset variables.dietIdVariable = 'diet-#LCase(Replace(variables.diets[variables.d], ' ', '-', 'all'))#' />

                            <div class="form-check form-check-inline col-md-3" style="white-space: nowrap; margin-right: 30px; ">
                                <input class="form-check-input" type="checkbox" name="diet" id="#variables.dietIdVariable#" value="#variables.diets[variables.d]#" />
                                <label class="form-check-label" for ="#variables.dietIdVariable#">#variables.diets[variables.d]#
                            </div>
                        </cfloop>  
                    </div>
                </div>
                
                <buutton id="search-btn" class="btn btn-primary float-right">Get recipes</button>
            </form>
        </div>
    </div>

    <div style="margin-bottom: 20px;"></div>
    
    <div class="card collaspe" id="search-results-card">
        <div class="card-header">Search Results</div>
        <div class="card-body" id="search-results-body">Please search above....</div>
    </div>

    <div class="modal" tabindex="-1" id="details-modal">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
            <div class="modal-content">
                <div class="modal-header card-header">
                    <h5 class="modal-title" id="recipe-title"></h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">

                    <div class="row">
                        <div class="col-md-12">
                            <img id="recipe-image" class="details-image mx-auto d-block" />
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-12 summary-text" id="recipe-summary"></div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <span class="bold">Cuisine:</span> <span id="recipe-cuisine"></span> 
                        </div>
                        <div class="col-md-6">
                            <span class="bold">Meal Type:</span> <span id="recipe-dishTypes" ></span> 
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <span class="bold">Diets:</span> <span id="recipe-diet" ></span> 
                        </div>
                        <div class="col-md-6">
                            <span class="bold">Servings:</span> <span id="recipe-servings" ></span> 
                        </div>
                    </div>

                     <div class="row">
                        <div class="col-md-6">
                            <span class="bold">Credit:</span> <span id="recipe-creditsText"></span> 
                        </div>
                        <div class="col-md-6">
                            <span class="bold">Source:</span> <span id="recipe-sourceName"><a id="recipe-sourceUrl"></a></span> 
                        </div>
                    </div>
                    
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</cfoutput>