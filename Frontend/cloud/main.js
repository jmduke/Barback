require('cloud/app.js');

function objectsForVariable(className, attribute, value, callback) {
  var query = new Parse.Query(className);
  query.equalTo(attribute, value);
  query.find({
    success: callback,
    error: function() {
      response.error(className + " lookup failed.");
    }
  });
}

Parse.Cloud.define("recipeForName", function(request, response) {
  objectsForVariable("Recipe", "name", request.params.name, function(recipes) {
    objectsForVariable("Ingredient", "recipe", request.params.name, function(ingredients) {
      recipe = recipes[0];
      recipe.attributes.ingredients = ingredients;
      response.success(recipe);
    });
  });
});

Parse.Cloud.define("ingredientForName", function(request, response) {
  objectsForVariable("IngredientBase", "name", request.params.name, function(bases) {
    base = bases[0];
    objectsForVariable("Brand", "base", request.params.name, function(brands) {
      base.attributes.brands = brands;
      objectsForVariable("Ingredient", "base", request.params.name, function(ingredients) {
        base.attributes.ingredients = ingredients;
        response.success(base);
      });
    });
  });
});