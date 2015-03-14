require('cloud/app.js');
var _ = require('underscore');

// Returns list of tuples (hex, amount)
function visualDataForRecipe(ingredients, bases) {
  baseNames = _.map(bases, function(base) {
    return base.attributes.name;
  });
  return _.sortBy(_.map(ingredients, function(ingredient) {
    baseIndex = baseNames.indexOf(ingredient.attributes.base);
    color = baseIndex < 0 ? "ccc" : bases[baseIndex].attributes.color;
    return [color, ingredient.attributes.amount];
  }), function(visualTuple) {
    return visualTuple[1]
  });
}

function abvForRecipe(ingredients, bases) {
  nominator = 0;
  denominator = 0;  
  baseNames = _.map(bases, function(base) {
    return base.attributes.name;
  });
  _.each(ingredients, function(ingredient) {
    baseIndex = baseNames.indexOf(ingredient.attributes.base);
    abv = baseIndex < 0 ? 0 : bases[baseIndex].attributes.abv;
    amount = ingredient.attributes.amount;
    amount = amount == null ? 0 : amount;
    nominator += abv * amount;
    denominator += amount;
  });
  return Math.round(nominator / denominator);
}

function objectsForVariable(className, attribute, value, callback) {
  var query = new Parse.Query(className);
  query.limit(1000);
  query.descending("amount");
  query.equalTo(attribute, value);
  query.find({
    success: callback,
    error: function() {
      Parse.Error(className + " lookup failed.");
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

Parse.Cloud.define("allRecipes", function(request, response) {
  var results = {};

  retrieved_ingredients = [];
  retrieved_recipes = [];
  var query = new Parse.Query("Recipe");
  query.limit(1000);
  query.find().then(function(recipes) {
    retrieved_recipes = recipes;
    query = new Parse.Query("Ingredient");
    query.limit(1000);
    return query.find();
  }).then(function(ingredients) {
    retrieved_ingredients = ingredients;
    query = new Parse.Query("IngredientBase");
    return query.find();
  }).then(function(bases) {
    results["visualData"] = _.object(_.map(retrieved_recipes, function(recipe) {
      recipeIngredients = _.filter(retrieved_ingredients, function(ingredient) {
        return ingredient.attributes.recipe == recipe.attributes.name
      });
      return [recipe.attributes.name, visualDataForRecipe(recipeIngredients, bases)];
    }));
    results["abv"] =  _.object(_.map(retrieved_recipes, function(recipe) {
      recipeIngredients = _.filter(retrieved_ingredients, function(ingredient) {
        return ingredient.attributes.recipe == recipe.attributes.name
      });
      return [recipe.attributes.name, abvForRecipe(recipeIngredients, bases)];
    }));
    results["bases"] = _.object(_.map(retrieved_recipes, function(recipe) {
      recipeIngredients = _.filter(retrieved_ingredients, function(ingredient) {
        return ingredient.attributes.recipe == recipe.attributes.name
      });
      var ingredient_string = _.map(recipeIngredients, function(ingredient) {
        return ingredient.attributes.base
      }).join();
      return [recipe.attributes.name, ingredient_string];
    }));
    results["recipes"] = _.sortBy(_.filter(retrieved_recipes, function(recipe) {
      return results["visualData"][recipe.attributes.name].length > 1
    }), function(recipe) {
      return recipe.attributes.name
    });
    response.success(results);
  });
});


Parse.Cloud.define("recipeForName", function(request, response) {
  objectsForVariable("Recipe", "objectId", request.params.name, function(recipes) {
    recipe = recipes[0];
    objectsForVariable("Ingredient", "recipe", recipe.attributes.name, function(ingredients) {
      recipe.attributes.ingredients = ingredients;
      recipe.attributes.baseNames = _.map(ingredients, function(ingredient) {
        return ingredient.attributes.base;
      });

      objectsForVariables("IngredientBase", "name", recipe.attributes.baseNames, function(bases) {
        recipe.attributes.bases = _.object(_.map(bases, function(base) {
          return [base.attributes.name, base.id];
        }));
        recipe.attributes.visualData = visualDataForRecipe(ingredients, bases);
        recipe.attributes.abv = abvForRecipe(ingredients, bases);
        response.success(recipe);
      });
    });
  });
});

Parse.Cloud.define("ingredientForName", function(request, response) {
  objectsForVariable("IngredientBase", "objectId", request.params.name, function(bases) {
    base = bases[0];
    objectsForVariable("Brand", "base", request.params.name, function(brands) {
      base.attributes.brands = brands;
      objectsForVariable("Ingredient", "base", base.attributes.name, function(ingredients) {
        base.attributes.ingredients = ingredients;
        recipeNames = _.map(ingredients, function(ingredient) {
          return ingredient.attributes.recipe;
        });
        console.log(recipeNames);
        objectsForVariables("Recipe", "name", recipeNames, function(recipes) {
          console.log(recipes);
          base.attributes.recipes = _.object(_.map(recipes, function(recipe) {
            return [recipe.attributes.name, recipe.id]
          }));
          response.success(base);
        });
      });
    });
  });
});