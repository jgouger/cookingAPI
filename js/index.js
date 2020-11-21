$(document).ready(function()
{

    /**
     * Renders the Detail Information modal after a successful callback to the API
     * @param {object} data 
     * @returns {void}
     */
    var renderDetails = function (data)
    {
        // empty all content nodes
        var dataNodes = ['recipe-title', 'recipe-image', 'recipe-summary', 'recipe-cuisine', 'recipe-dishTypes', 'recipe-servings', 'recipe-creditsText', 'recipe-sourceName', 'recipe-sourceUrl'];
        var detailModal = $('#details-modal');
        var key = '';

        $(detailModal).modal('hide');

        for (var d = 0; d < dataNodes.length; d++)
        {
            if (! (dataNodes[d] === 'recipe-sourceUrl' || dataNodes[d] === 'recipe-sourceName') )
            {
                $('#' + dataNodes[d]).empty();
            }
            else
            {
                if (dataNodes[d] === 'recipe-sourceUrl')
                {
                    $('#' + dataNodes[d]).prop('href', '');
                }
                else if (dataNodes[d] === 'recipe-sourceName')
                {
                    $('#' + dataNodes[d]).find('a').html() ;
                }
            }

            key = dataNodes[d].split("-")[1];

            if (dataNodes[d] === 'recipe-image')
            {
                $('#' + dataNodes[d]).prop('src', '');
            }
            
            for (var k in data)
            {
                if (data.hasOwnProperty(k) && k === key)
                {
                    if (dataNodes[d] === 'recipe-image')
                    {
                        $('#' + dataNodes[d]).prop('src', data[k]);
                    }
                    else if (dataNodes[d] === 'recipe-sourceUrl')
                    {
                        $('#' + dataNodes[d]).prop('href', data[k]);
                    }
                    else if (dataNodes[d] === 'recipe-sourceName')
                    {
                        $('#' + dataNodes[d]).find('a').html(data[k]) ;
                    }
                    else
                    {
                        if (typeof(data[k]) !== 'object')
                        {
                            $('#' + dataNodes[d]).html(data[k].toString().replace('\"', '"') );
                        }
                        else if (typeof(data[k]) === 'object' && Array.isArray(data[k]) )
                        {
                            $('#' + dataNodes[d]).html(data[k].join(', '));
                        }
                    }

                    break;
                }
            }
        }

        $(detailModal).modal('show');
    };

    /**
     * Gets the Details of the recipe from the API Service.
     * @param {object} jQuery event object 
     * * @returns {void}
     */
    var getDetails = function (e)
    {
        var currentTarget = $(e)[0].currentTarget;

        var recipeId = parseInt($(currentTarget).data('recipe-id'));

        $.ajax({
            method: 'post',
            url: 'controller/spoonacular.cfc?method=getDetails',
            data: 
            {
                recipeId: recipeId
            }
        }).done(function(data)
        {
            var responseData = JSON.parse(data);
            
            // API call was successful. Build the Cards
            if (responseData.success)
            {
                renderDetails(responseData.results);
            }

            else
            {
                alert('An error occurred while connecting to the API.' + responseData.msg);
            }

        });
    };

    /**
     * Renders the recipes after a successful callback to the API
     * @param {object} data 
     * @returns {void}
     */
    var renderRecipe = function(data)
    {
        var searchResults = $('#search-results-body');

        $(searchResults).empty();

        var recipeHTML = '<div class="card-group card-group-layout"><div class="row flex-nowrap-a">';

        for (var r = 0; r < data.results.length; r++)
        {
            recipeHTML += '<div class="card col-md-4 recipe-card" data-recipe-id="' + data.results[r].id + '">' +
                '<img class="card-img-top recipe-image" src="' + data.results[r].image + '" title="' + data.results[r].title + '"/>' +
                '<div class="card-body">' + 
                    '<h6 class="card-title">' + data.results[r].title + '</h6>' +
                '</div>' +
            '</div>';

            if (r > 0 && (r + 1) % 3 == 0)
            {
                recipeHTML += '</div><div class="row flex-nowrap-a">';
            }
            else if (r == data.results.length - 1)
            {
                // create empty cards so the that layout looks corect
                if (data.results.length % 3 == 2)
                {
                    recipeHTML += '<div class="card col-md-4 recipe-card">' +
                        '<div class="card-img-top recipe-image" />' +
                        '<div class="card-body">' + 
                            '<h6 class="card-title"></h6>' +
                        '</div>' +
                    '</div>';

                    recipeHTML += '<div class="card col-md-4 recipe-card">' +
                        '<div class="card-img-top recipe-image" />' +
                        '<div class="card-body">' + 
                            '<h6 class="card-title"></h6>' +
                        '</div>' +
                    '</div>';
                }

                if (data.results.length % 3 == 1)
                {
                    recipeHTML += '<div class="card col-md-4 recipe-card">' +
                        '<div class="card-img-top recipe-image" />' +
                        '<div class="card-body">' + 
                            '<h6 class="card-title"></h6>' +
                        '</div>' +
                    '</div>';
                }

                recipeHTML += '</div>';
            }
        }

        recipeHTML += '</div>';

        $(searchResults).append(recipeHTML);

        $(".recipe-card").click(function (e) 
        {
            getDetails(e); 
        } );

    };

    /**
     * Event handler function for the search button
     * @param {object} jQuery event object
     * @returns {void}
     */
    $('#search-btn').click(function(e)
    {
        $.ajax({
            method: 'post',
            url: 'controller/spoonacular.cfc?method=search',
            data: $(this).parent('form').serialize()
        }).done(function(data)
        {
            var responseData = JSON.parse(data);
            
            // API call was successful. Build the Cards
            if (responseData.success)
            {
               renderRecipe(responseData.results);
            }

            else
            {
                alert('An error occurred while connecting to the API.' + responseData.msg);
            }

        });

    });

});