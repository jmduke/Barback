
// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'jade');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

app.get('/app', function(req, res) {
  res.render('app', { message: "" });
});

app.get('/', function(req, res) {
  var recipes = Parse.Cloud.run("allRecipes", {}, {
    success: function(results) {
      res.render('recipes', { message: results });
    },
    error: function() {
      res.render('error', { message: "asasd"});
    }
  });
});

app.get('/recipe/:name', function(req, res) {
  if (req.xhr) {
    var recipe = Parse.Cloud.run("recipeForName", {"name": req.param("name")}, {
      success: function(results) {
        res.json(results);
      },
      error: function() {
        res.render('error', { message: "lolfail"});
      }
    });
  } else {
    var recipes = Parse.Cloud.run("allRecipes", {}, {
      success: function(results) {
        res.render('recipes', { message: results });
      },
      error: function() {
        res.render('error', { message: "asasd"});
      }
    });
  }
});

app.get('/ingredient/:name', function(req, res) {
  console.log(req.xhr);
  if (req.xhr) {
    var recipe = Parse.Cloud.run("ingredientForName", {"name": req.param("name")}, {
      success: function(results) {
        res.json(results);
      },
      error: function() {
        res.render('error', { message: "lolfail"});
      }
    });
   } else {
    var recipes = Parse.Cloud.run("allRecipes", {}, {
      success: function(results) {
        res.render('recipes', { message: results });
      },
      error: function() {
        res.render('error', { message: "asasd"});
      }
    });
  }
});

app.listen();