
// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'jade');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

app.get('/recipe/:name', function(req, res) {
  var recipe = Parse.Cloud.run("recipeForName", {"name": req.param("name")}, {
    success: function(results) {
      res.render('recipe', { message: results });
    },
    error: function() {
      res.render('error', { message: "lolfail"});
    }
  });
});

app.get('/search/:term', function(req, res) {
  var recipe = Parse.Cloud.run("searchForTerm", {"term": req.param("term")}, {
    success: function(results) {
      res.render('search', { message: results });
    },
    error: function() {
      res.render('error', { message: "lolfail"});
    }
  });
});

app.get('/ingredient/:name', function(req, res) {
  var recipe = Parse.Cloud.run("ingredientForName", {"name": req.param("name")}, {
    success: function(results) {
      res.render('ingredient', { message: results });
    },
    error: function() {
      res.render('error', { message: "lolfail"});
    }
  });
});

app.listen();