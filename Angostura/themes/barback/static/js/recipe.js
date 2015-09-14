function abv(ingredients) {
  var totalAlcohol = 0;
  var totalVolume = 0;
  for (var index in ingredients) {
    var ingredient = ingredients[index];
    var base = ingredient.base;
    if (!ingredient.amount) {
      continue;
    }

    if (base && base.abv) {
      totalAlcohol += (ingredient.amount * base.abv);
    }
    totalVolume += ingredient.amount;
  }
  return (totalAlcohol / totalVolume).toFixed(0);
}

function drawRecipe(glass, ingredients, selector) {

    // Bunch of constants and such.
    var GLASSWARE = {
        "champagne flute": [100, 0, 30],
        "cocktail": [50, 0, 60],
        "collins": [100, 40, 40],
        "goblet": [100, 0, 100],
        "hurricane": [100, 50, 80],
        "highball": [100, 40, 40],
        "mug": [60, 80, 80],
        "old fashioned": [60, 80, 80],
        "rocks": [60, 80, 80],
        "shot": [40, 30, 40],
        "margarita": [50, 10, 90],
        "martini": [50, 0, 60],
    };
    var FALLBACK_GLASS = "cocktail";
    var FALLBACK_COLOR = "#333";
    var BACKGROUND_COLOR = "#FFF";
    var EMPTY_SPACE_RATIO = 0.2;
    var PADDING = 3;


    // Get the dimensions and canvas size.
    var dimensions = GLASSWARE[glass];
    if (!dimensions) {
        dimensions = GLASSWARE[FALLBACK_GLASS];
    }
    var height = dimensions[0] * 2;
    var width_1 = dimensions[1] * 2;
    var width_2 = dimensions[2] * 2;
    var inset = (width_2 - width_1) / 2;
    

    // Total amount of cl/oz in the recipe.
    var ingredientDenominator = 0;
    for (i = 0; i < ingredients.length; i++) {
        var ingredientAmount = ingredients[i].amount;
        if (!ingredientAmount) {
            ingredientAmount = 0;
        }
        ingredientDenominator += ingredientAmount;
    }
     
    // Ratios for each ingredient.  This is pretty gross.   
    var ratios = [0.0, 0.0, EMPTY_SPACE_RATIO];
    for (i = 0; i < ingredients.length; i++) {
        var ingredientAmount = ingredients[i].amount;
        if (!ingredientAmount) {
            ingredientAmount = 0;
        }
        ratios.push((1 - EMPTY_SPACE_RATIO) * ingredientAmount / ingredientDenominator + ratios[i+2]);
    }
 
    var canvas = SVG(selector).size(width_2 + PADDING * 4, height + PADDING * ratios.length);
    for (var i in ratios) {

        var ratio = ratios[i];

        // Subtract two because we add two empty elements to ratios.
        var ingredient = ingredients[i - 2];
        if (i > 1 && !ingredient) {
            continue;
        }

        // Get color for ratio.
        var fill_color = BACKGROUND_COLOR;
        if (i > 1) {
            if (ingredient && ingredient.base && bases[ingredient.base]) {
                fill_color = "#" + bases[ingredient.base].color;
            } else if (ingredient && ingredient.base.color) {
                fill_color = "#" + ingredient.base.color;
            } else {
                fill_color = FALLBACK_COLOR;
            }
        }

        var padding_offset = i > 1 ? PADDING * i : PADDING * (ratios.length - 2);

        var bottom_left = "" + (inset + PADDING) + ',' + (height +  padding_offset);
        var bottom_right = "" + (width_2 - inset + PADDING) + ',' + (height + padding_offset);
        var top_right = "" + (width_2 - (inset * ratio) + PADDING) + ',' + (height * ratio + padding_offset);
        var top_left = "" + (inset * ratio + PADDING) + ',' + (height * ratio + padding_offset);

        var poly = canvas.polygon("" + bottom_left + ' ' + bottom_right + ' ' + top_right + ' ' + top_left).fill(fill_color);
        
        if (i == 0) {
            var strokeWidth = PADDING * 2;
            var strokeColor = "#000";
        } else {
            var strokeWidth = PADDING;
            var strokeColor = "#fff";
        }
        poly.stroke({ width: strokeWidth, color: strokeColor });
    }
}