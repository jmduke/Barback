var container = $('.recipes');

container.isotope({
  itemSelector: '.recipe',
  layoutMode: 'masonry',
  getSortData: {
    name: '[data-name]',
    abv: function (element) {
    	var ingredients = recipes[$(element).attr("data-name")].ingredients;
    	var totalAlcohol = 0;
    	var totalVolume = 0;
    	for (var index in ingredients) {
    		var ingredient = ingredients[index];
    		var base = bases[ingredient.base];
    		if (!ingredient.amount) {
    			continue;
    		}

    		if (base && base.abv) {
	    		totalAlcohol += (ingredient.amount * base.abv);
	    	}
	    	totalVolume += ingredient.amount;
    	}
    	return (totalAlcohol / totalVolume);
    },
    complexity: function (element) {
      return recipes[$(element).attr("data-name")].ingredients.length;
    }
  }
});

$("#search_filter").on("keypress paste focus textInput input", function() {
  var value = $(this).val();
  container.isotope({ 
  	filter: function() {
      var name = $(this).attr("data-name");
      var ingredients = $(this).attr("data-ingredients");
      var searchTermInName = name.toUpperCase().indexOf(value.toUpperCase()) > -1;
      var searchTermInIngredients = ingredients.toUpperCase().indexOf(value.toUpperCase()) > -1;
      return searchTermInName || searchTermInIngredients;
    }
  });
});

$("h4 a").click(function(event) {
  event.preventDefault();
  var sortBy = $(this).attr("id");

  var previousText = $(this).text();
  var sort_links = $("h4 a");
  for (i = 0; i < sort_links.length; i++) {
    $(sort_links[i]).text($(sort_links[i]).text().replace(/[^a-z0-9\s]/gi, ''));
  }


  if (previousText.indexOf("↓") < 0) {
  	var sortAscending = false;
  	var sortDirection = "↓";
  } else {
  	var sortAscending = true;
  	var sortDirection = "↑";
  }

  $(this).text($(this).text() + sortDirection);
  container.isotope({ sortBy: sortBy, sortAscending: sortAscending });
});