function drawRecipe(glass, ingredients, selector) {
    glassware = {
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

    glasses = ["hurricane", "highball", "old fashioned", "martini", "champagne"];

    dimensions = glassware[glass];
    height = dimensions[0] * 2;
    width_1 = dimensions[1] * 2;
    width_2 = dimensions[2] * 2;
    
    inset = (width_2 - width_1) / 2;
    


    var total_count = 0;
    for (i = 0; i < ingredients.length; i++) {
        total_count += ingredients[i][1];
    }
    
    empty_space = 0.2;
    padding = 3;
        
    ratios = [0.0, 0.0, empty_space];
    for (i = 0; i < ingredients.length; i++) {
        ingredient = ingredients[i][1];
        ratios.push((1 - empty_space) * ingredient / total_count + ratios[i+2]);
    }
 
    var pol = SVG(selector).size(width_2 + padding * 4, height + padding * ratios.length);
    for (i = 0; i < ratios.length - 1; i++) {
        ratio = ratios[i];
        fill_color = i > 1 ? "#" + ingredients[i - 2][0] : "#fff";
        padding_offset = i > 1 ? padding * i : padding * (ratios.length - 2);
        
        bottom_left = "" + (inset + padding) + ',' + (height +  padding_offset);
        bottom_right = "" + (width_2 - inset + padding) + ',' + (height + padding_offset);
        top_right = "" + (width_2 - (inset * ratio) + padding) + ',' + (height * ratio + padding_offset);
        top_left = "" + (inset * ratio + padding) + ',' + (height * ratio + padding_offset);
        
        poly = pol.polygon("" + bottom_left + ' ' + bottom_right + ' ' + top_right + ' ' + top_left).fill(fill_color)
        
        if (i == 0) {
            stroke_width = padding * 2;
        } else if (i == 1) {
            stroke_width = padding;
        } else {
            stroke_width = padding;
        }
        stroke_color = i > 0 ? "#fff" : "#000";
        poly.stroke({ width: stroke_width, color: stroke_color });
    }
}