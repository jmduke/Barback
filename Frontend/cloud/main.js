require('cloud/app.js');

function objectsForVariable(className, attribute, value, callback) {
  var query = new Parse.Query(className);
  query.descending("amount");
  query.equalTo(attribute, value);
  query.find({
    success: callback,
    error: function() {
      response.error(className + " lookup failed.");
    }
  });
}

function objectsForVariables(className, attribute, values, callback) {
  var query = new Parse.Query(className);
  query.containedIn(attribute, values);
  query.find({
    success: callback,
    error: function() {
      response.error(className + " lookup failed.");
    }
  });
}

Parse.Cloud.define("incrementFavoritesForRecipe", function(request, response) {
  objectsForVariable("Recipe", "name", request.params.name, function(recipes) {
    recipe = recipes[0];
    if (request.params.increment) {
      recipe.increment("favorites");
    } else {
      recipe.increment("favorites", -1);
    }
    recipe.save();
    response.success();
  });
});

Parse.Cloud.define("searchForTerm", function(request, response) {
  var term = request.params.term;
  var results = {"term": term};

  var query = new Parse.Query("Recipe");
  query.contains("name", term);
  query.find().then(function(recipes) {
    results["recipes"] = recipes;
    query = new Parse.Query("IngredientBase");
    query.contains("name", term);
    return query.find();
  }).then(function(ingredients) {
    results["ingredients"] = ingredients;
    response.success(results);
  });
});

Parse.Cloud.define("recipeForName", function(request, response) {
  objectsForVariable("Recipe", "name", request.params.name, function(recipes) {
    recipe = recipes[0];
    objectsForVariable("Ingredient", "recipe", request.params.name, function(ingredients) {
      recipes_left = ingredients.length;
      recipe.attributes.ingredients = ingredients;
      baseNames = [];
      for (i = 0; i < ingredients.length; i++) {
        baseNames.push(ingredients[i].attributes.base);
      }
      objectsForVariables("IngredientBase", "name", baseNames, function(bases) {
        recipe.attributes.bases = [];
        nominator = 0.0;
        denominator = 0.0;
        for (j = 0; j < bases.length; j++) {
          base = bases[j];
          recipe.attributes.bases.push(base.attributes.name);
          abv = base.attributes.abv;
          amount = ingredients[baseNames.indexOf(base.attributes.name)].attributes.amount;
          if ((abv > 0) && (amount > 0)) {
            nominator += abv * amount;
            denominator += amount;
          } else if (amount > 0) {
            denominator += amount;
          }
        }
        recipe.attributes.nominator = nominator;
        recipe.attributes.denominator = denominator;
        recipe.attributes.abv = Math.round(nominator / denominator);
        response.success(recipe);
      });
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