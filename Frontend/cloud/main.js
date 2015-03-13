require('cloud/app.js');
var _ = require('underscore');

// Returns list of tuples (hex, amount)
function visualDataForRecipe(ingredients, bases) {
  baseNames = _.map(bases, function(base) {
    return base.attributes.name;
  });
  return _.sortBy(_.map(ingredients, function(ingredient) {
    baseIndex = baseNames.indexOf(ingredient.attributes.base);
    if (baseIndex < 0) {
      color = "ccc";
    } else {
      color = bases[baseIndex].attributes.color;
    }
    return [color, ingredient.attributes.amount];
  }), function(visualTuple) {
    return visualTuple[1]
  });
}

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
    results["recipes"] = _.sortBy(_.filter(retrieved_recipes, function(recipe) {
      return results["visualData"][recipe.attributes.name].length > 1
    }), function(recipe) {
      return recipe.attributes.name
    });
    response.success(results);
  });
});


Parse.Cloud.define("recipeForName", function(request, response) {
  objectsForVariable("Recipe", "name", request.params.name, function(recipes) {
    recipe = recipes[0];
    objectsForVariable("Ingredient", "recipe", request.params.name, function(ingredients) {
      recipe.attributes.ingredients = ingredients;
      baseNames = _.map(ingredients, function(ingredient) {
        return ingredient.attributes.base;
      });
      objectsForVariables("IngredientBase", "name", baseNames, function(bases) {
        recipe.attributes.bases = [];
        recipe.attributes.visualData = []; 
        recipe.attributes.nominator = 0.0;
        recipe.attributes.denominator = 0.0;
        _.each(bases, function(base) {
          recipe.attributes.bases.push(base.attributes.name);
          abv = base.attributes.abv;
          amount = ingredients[baseNames.indexOf(base.attributes.name)].attributes.amount;
          amount = amount == null ? 0 : amount;
          recipe.attributes.nominator += abv * amount;
          recipe.attributes.denominator += amount;
        });

        recipe.attributes.visualData = visualDataForRecipe(ingredients, bases);
        recipe.attributes.abv = Math.round(recipe.attributes.nominator / recipe.attributes.denominator);
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