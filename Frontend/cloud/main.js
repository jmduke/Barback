require('cloud/app.js');
var _ = require('underscore');

// Returns list of tuples (hex, amount)
function visualDataForRecipe(ingredients) {
  return _.sortBy(_.map(ingredients, function(ingredient) {
    color = ingredient.attributes.base.attributes.color;
    return [color, ingredient.attributes.amount];
  }), function(visualTuple) {
    return visualTuple[1]
  });
}

function abvForRecipe(ingredients) {
  nominator = 0;
  denominator = 0;  
  _.each(ingredients, function(ingredient) {
    abv = ingredient.attributes.base.attributes.abv;
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
  if (className == "Ingredient") {
    query.include("base");
    query.include("recipe");
  }
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
  if (className == "Ingredient") {
    query.include("base");
    query.include("recipe");
  }
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

Parse.Cloud.define("allRecipes", function(request, response) {
  var results = {};

  retrieved_ingredients = [];
  retrieved_recipes = [];
  var query = new Parse.Query("Recipe");
  query.limit(1000);
  query.find().then(function(recipes) {
    retrieved_recipes = recipes;
    query = new Parse.Query("Ingredient");
    query.include("base");
    query.include("recipe");
    query.limit(1000);
    return query.find();
  }).then(function(ingredients) {
    retrieved_ingredients = ingredients;
    query = new Parse.Query("IngredientBase");
    query.limit(1000);
    return query.find();
  }).then(function(bases) {
    results["visualData"] = _.object(_.map(retrieved_recipes, function(recipe) {
      recipeIngredients = _.filter(retrieved_ingredients, function(ingredient) {
        return ingredient.attributes.recipe.attributes.name == recipe.attributes.name
      });
      return [recipe.attributes.name, visualDataForRecipe(recipeIngredients, bases)];
    }));
    results["abv"] =  _.object(_.map(retrieved_recipes, function(recipe) {
      recipeIngredients = _.filter(retrieved_ingredients, function(ingredient) {
        return ingredient.attributes.recipe == recipe
      });
      return [recipe.attributes.name, abvForRecipe(recipeIngredients, bases)];
    }));
    results["bases"] = _.object(_.map(retrieved_recipes, function(recipe) {
      recipeIngredients = _.filter(retrieved_ingredients, function(ingredient) {
        return ingredient.attributes.recipe == recipe
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
  objectsForVariable("Recipe", "slug", request.params.name, function(recipes) {
    recipe = recipes[0];
    objectsForVariable("Ingredient", "recipe", recipe, function(ingredients) {
      recipe.attributes.ingredients = ingredients;
      recipe.attributes.bases = _.map(ingredients, function(ingredient) {
        return ingredient.attributes.base;
      });

      objectsForVariables("IngredientBase", "name", recipe.attributes.baseNames, function(bases) {
        recipe.attributes.bases = _.object(_.map(bases, function(base) {
          return [base.attributes.name, base.attributes.slug];
        }));
        recipe.attributes.visualData = visualDataForRecipe(ingredients, bases);
        recipe.attributes.abv = abvForRecipe(ingredients);
        recipe.attributes._ingredients = JSON.stringify(ingredients);
        recipe.attributes._bases = JSON.stringify(_.map(ingredients, function(ingredient) {
          return ingredient.attributes.base
        }));
        response.success(recipe);
      });
    });
  });
});

Parse.Cloud.define("ingredientForName", function(request, response) {
  objectsForVariable("IngredientBase", "slug", request.params.name, function(bases) {
    base = bases[0];
    objectsForVariable("Brand", "base", base, function(brands) {
      base.attributes.brands = JSON.stringify(brands);
      objectsForVariable("Ingredient", "base", base, function(ingredients) {
        base.attributes.ingredients = JSON.stringify(ingredients);
        base.attributes.recipes = JSON.stringify(_.map(ingredients, function(ingredient) {
          return ingredient.attributes.recipe;
        }));
        response.success(base);
      });
    });
  });
});