function abv(ingredients) {
  var totalAlcohol = 0;
  var totalVolume = 0;
  for (var index in ingredients) {
    var ingredient = ingredients[index];
    var base = ingredient.baseName;
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
    var heightOffset = 6;
    var widthOffset = 6;


    // Get the dimensions and canvas size.
    var dimensions = GLASSWARE[glass];
    if (!dimensions) {
        dimensions = GLASSWARE[FALLBACK_GLASS];
    }

    var height = dimensions[0] * 2;
    var bottomWidth = dimensions[1] * 2;
    var topWidth = dimensions[2] * 2;

    var inset = (topWidth - bottomWidth) / 2;
    
    var totalVolume = _.sum(_.map(ingredients, 'amount'));
    
    var viewSegments = []
    viewSegments.push([0.0, "000"]);

    var sortedIngredients = _.sortBy(ingredients, "amount");

    var whitespaceModifier = (1.0 - EMPTY_SPACE_RATIO) / totalVolume;
    _.forEach(sortedIngredients, function(ingredient) {
        var ratioFraction = ingredient.amount * whitespaceModifier;

        var base = ingredient.baseName;
        if (!base.color) {
            base = bases[ingredient.baseName];
        }
        if (!base) {
            base = {'color': "999"};
        }
        if (base && !isNaN(ratioFraction)) {
            var previousRatioFraction = viewSegments[viewSegments.length - 1][0];
            viewSegments.push([ratioFraction + previousRatioFraction, base.color]);
        }
    });

    viewSegments.push([1.0, "fff"]);

    var canvas = SVG(selector).size(topWidth + PADDING * 4, height + PADDING * viewSegments.length);
    
    _.forEach(viewSegments, function(viewSegment, segmentIndex) {

        var ratio = viewSegment[0];
        var previousRatio = segmentIndex > 0 ? viewSegments[segmentIndex - 1][0] : ratio;

        var proportionOfSpaceBeforeSegment = 1 - previousRatio;
        var proportionOfSpaceAfterSegment = 1 - ratio;

        var bottomOfSegment = heightOffset + height * proportionOfSpaceBeforeSegment;
        var topOfSegment = heightOffset + height * proportionOfSpaceAfterSegment;

        var bottomLeft = [widthOffset + inset * proportionOfSpaceBeforeSegment, bottomOfSegment];
        var bottomRight = [widthOffset + topWidth - (inset * proportionOfSpaceBeforeSegment), bottomOfSegment];
        var topRight = [widthOffset + topWidth - (inset * proportionOfSpaceAfterSegment), topOfSegment];
        var topLeft = [widthOffset + inset * proportionOfSpaceAfterSegment, topOfSegment];

        // Convert into strings.
        var coordinateStrings = _.map([bottomLeft, bottomRight, topRight, topLeft], function(coordinate) {
            return " " + coordinate[0] + "," + coordinate[1]
        })

        // And concatenate.
        var polygonString = coordinateStrings.join("");

        var fillColor = "#" + viewSegment[1];
        var polygon = canvas.polygon(polygonString).fill(fillColor);

        if (segmentIndex == 0) {
            var strokeWidth = PADDING * 2;
            var strokeColor = "#000";
        } else {
            var strokeWidth = PADDING;
            var strokeColor = "#FFF";
        }
        polygon.stroke({ width: strokeWidth, color: strokeColor });
    });

    var strokeWidth = 3;

    var bottomOfGlass = heightOffset + height + strokeWidth;
    var topOfGlass = heightOffset;

    var bottomExtra = bottomWidth == 0 ? 0 : strokeWidth;

    var bottomLeft = [widthOffset + inset - bottomExtra, bottomOfGlass];
    var bottomRight = [widthOffset + topWidth - inset + bottomExtra, bottomOfGlass];
    var topRight = [widthOffset + topWidth + strokeWidth, topOfGlass];
    var topLeft = [widthOffset - strokeWidth, topOfGlass];

    // Convert into strings.
    var coordinateStrings = _.map([bottomLeft, bottomRight, topRight, topLeft], function(coordinate) {
        return " " + coordinate[0] + "," + coordinate[1]
    })

    // And concatenate.
    var polygonString = coordinateStrings.join("");

    canvas.polygon(polygonString).attr({'fill-opacity': 0}).stroke({ width: strokeWidth, color: '#666' });
}