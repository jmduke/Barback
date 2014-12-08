require('cloud/app.js');

Parse.Cloud.define("recipeForName", function(request, response) {
  var query = new Parse.Query("Recipe");
  query.equalTo("name", request.params.name);
  query.find({
    success: function(results) {
      var query = new Parse.Query("Ingredient");
      query.equalTo("recipe", request.params.name);
      query.find({
        success: function(results2) {
          results[0].attributes.ingredients = results2;
          response.success(results[0]);
        },
        error: function() {
          response.error("movie lookup failed");
        }
      });
    },
    error: function() {
      response.error("movie lookup failed");
    }
  });
});