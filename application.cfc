component
{
    this.name = "cookingAPI";
    this.sessionManagement = true;
    this.sessionTimeout = CreateTimeSpan(1,0,0,0);
    this.scriptProtect = true;

    public boolean function onApplicationStart()
    {
        return true;
    }

    public boolean function onRequestStart(required string targetPage)
    {
        this.jsLibraries = 
        [
            'libs/jQuery/jquery-3.5.1.min.js',
            'libs/bootstrap-4.5.3-dist/js/bootstrap.min.js',
            'js/index.js'
        ];

        this.stylesheets =
        [
            'libs/bootstrap-4.5.3-dist/css/bootstrap.min.css',
            'css/index.css'
        ]

        return true;
    }

    public void function onRequest (required string targetPage)
    {
        if (! StructKeyExists(request, 'title') )
        {
            request.title = 'Receipe API Project';
        }

        request.controller = new controller.spoonacular();

        // this will actually render the HTML content
        writeOutput(beginHTML(request.title));
            include arguments.targetPage;
        writeOutput(endHTML());
    }


    /**
    * Builds the HTML for any CSS files used. 
    * @return the HTML for any css files used
    */
    private string function initCSS()
    {
        saveContent variable = "local.cssFiles"
        {
            for (local.i = 1; local.i <= ArrayLen(this.stylesheets); local.i++)
            {
                writeOutput('<link href="#this.stylesheets[local.i]#" rel="stylesheet" type="text/css" />');
            }
        }

        return local.cssFiles;
    }

    /**
    * Builds the HTML for any Javascript files used. 
    * @return the HTML for any javascript files used
    */
    private string function initJavascript()
    {
        var local = {};

        saveContent variable = "local.jsFiles"
        {
            for (local.i = 1; local.i <= ArrayLen(this.jsLibraries); local.i++)
            {
                 writeOutput('<script type="text/javascript" src="#this.jsLibraries[local.i]#"></script>');
            }
        }

        return local.jsFiles;
    }

    /**
    * Builds the start of the HTML document
    * @pageTitle string Value to display in the browsers window
    * @return partial HTML string
    */
    private string function beginHTML(required string pageTitle)
    {
        saveContent variable = "local.beginningHTML"
        {
            writeOutput('<!DOCTYPE html>
                <html>  
                    <head>  
                        <title>#Arguments.pageTitle#</title> 
                        <!-- Required meta tags -->  
                        <meta charset="utf-8"> 
                        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"> 
                        #initCss()# 
                    </head>  
                    <body> 
                        <div class="container">'
            );

        };

        return local.beginningHTML;

    }

    /**
    * Builds the end of the HTML document
    * @return partial HTML string
    */
    private string function endHTML()
    {
        saveContent variable = "local.endingHTML"
        {
            writeOutput(                        
                        '</div>
                        #initJavaScript()#
                    </body>
                </html>'
            );
        }

        return local.endingHTML;
    }
}