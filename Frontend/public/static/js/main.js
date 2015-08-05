var container = $('.recipes');
container.isotope({
  itemSelector: '.recipe',
  layoutMode: 'masonry',
  getSortData: {
    abv: '[data-abv] parseInt',
    name: '[data-name]',
    complexity: function (element) {
      return $(element).attr("data-ingredients").split(",").length;
    }
  }
});

/* Hide jumbotron and keep track of it via cookie. */
var jumbotronCookieName = "jumbotronCookie";
if (Cookies.get(jumbotronCookieName)) {
  $('.closebutton').parent().hide();
} else {
  $('.closebutton').parent().slideDown();
}
$('.closebutton').click(function(el) {
  $(this).parent().slideUp();
  Cookies.set(jumbotronCookieName, true);
});

$("h4 a").click(function(event) {
  event.preventDefault();
  var container = $('.recipes');
  var sortBy = $(this).attr("id");
  var sortAscending = false;

  var previousText = $(this).text();
  var sort_links = $("h4 a");
  for (i = 0; i < sort_links.length; i++) {
    $(sort_links[i]).text($(sort_links[i]).text().replace(/[^a-z0-9\s]/gi, ''));
  }

  if (previousText.indexOf("↓") < 0) {
    $(this).text($(this).text() + "↓");
  } else {
    $(this).text($(this).text() + "↑");
    sortAscending = true;
  }

  container.isotope({ sortBy: sortBy, sortAscending: sortAscending });

});
$("#search_filter").on("keypress paste focus textInput input", function() {
  value = $(this).val();
  var container = $('.recipes');
  container.isotope({ filter: function() {
    var name = $(this).attr("data-name");
    var ingredients = $(this).attr("data-ingredients");
    return name.toUpperCase().indexOf(value.toUpperCase()) > -1 || ingredients.toUpperCase().indexOf(value.toUpperCase()) > -1 ;
  }});
});

var label = function(i){
  if (i.amount && i.label) {
    return i.label + " · " + i.amount + " cl"
  } else if (i.amount) { 
    return i.amount + " cl"
  } else if (i.label) {
    return i.label
  } else return ""
}

// Be less janky soon.
$(".recipes a").click(function(e) {
  href = $(this).attr("href");
  window.history.pushState("object or string", "Title", href);
  $(".greylay").css('visibility','visible').hide().fadeIn();
  $.ajax({
    url: href,
    success: function(recipe) {
      recipe._ingredients = JSON.parse(recipe._ingredients);
      recipe._bases = JSON.parse(recipe._bases);

      $("#data-recipe-name").text(recipe.name);
      $("#data-recipe-abv").text(recipe.abv + "% ABV");
      $("#data-recipe-glassware").text("Served in " + recipe.glassware + " glass");

      if (recipe.garnish) {
        $("#data-recipe-garnish").text("Garnish with " + recipe.garnish);
      } else {
        $("#data-recipe-garnish").text("No garnish");
      }

      $("#data-recipe-diagram").empty();
      drawRecipe(recipe.glassware, recipe.visualData, "data-recipe-diagram");
      $("#data-recipe-directions").text(recipe.directions);

      if (recipe.information) {
        $("#data-recipe-information-label").show();
        $("#data-recipe-information").show();
        $("#data-recipe-information")[0].innerHTML = marked(recipe.information);
      } else {
        $("#data-recipe-information-label").hide();
        $("#data-recipe-information").hide();
      }


      $("#data-recipe-ingredients").empty();
      $.each(recipe._ingredients, function(index, ingredient) {
        $("#data-recipe-ingredients").append("<ul><a class='ingredient ingredient-link' href='/ingredient/" 
                                           + recipe._bases[index].slug
                                          + "'>" 
                                          + recipe._bases[index].name
                                          + "</a><span class='details'>"
                                          + label(ingredient)
                                          + "</span></ul>");
      });
      $("#overlay").css('visibility','visible').hide().fadeIn();
    }
  });
  e.preventDefault();
});

$(".greylay").click(function(e) {
  $("#overlay").fadeOut(function(e) {
    window.history.pushState("object or string", "Title", "/");
    $(".greylay").fadeOut();
  });
  $("#ingredient-overlay").fadeOut(function(e) {
    window.history.pushState("object or string", "Title", "/");
    $(".greylay").fadeOut();
  });
});

$(document).ready(function() {
  path = window.location.pathname;
  if (path.indexOf("recipe") > 0) {
    $("a[href='" + path + "']").click();
  } 
  if (path.indexOf("ingredient") > 0) {
    loadIngredient(path);
  }
});

var loadIngredient = function(href) {
  $(".greylay").css('visibility','visible').hide().fadeIn();
  window.history.pushState("object or string", "Title", href);
    $.ajax({
    url: href,
    success: function(base) {
      base.brands = JSON.parse(base.brands);
      base.recipes = JSON.parse(base.recipes);
      base.ingredients = JSON.parse(base.ingredients);

      $("#data-ingredient-name").text(base.name);
      $("#data-ingredient-type").text(base.type);
      $("#data-ingredient-abv").text(base.abv + "% ABV");

      $("#data-ingredient-diagram").css("background-color", "#" + base.color);

      if (base.information) {
        $("#data-ingredient-information-label").show();
        $("#data-ingredient-information").show();
        $("#data-ingredient-information")[0].innerHTML = marked(base.information);
      } else {
        $("#data-ingredient-information-label").hide();
        $("#data-ingredient-information").hide();
      }


      if (base.brands.length > 0) {
        $("#data-ingredient-brands-label").show();
        $("#data-ingredient-brands").empty();
        $.each(base.brands, function(index, brand) {
          $("#data-ingredient-brands").append("<ul>"
                                              + brand.name
                                              + "</ul>");
        });
      } else {
        $("#data-ingredient-brands-label").hide();
      }

      $("#data-ingredient-uses").empty();
      $.each(base.recipes, function(index, recipe) {
        $("#data-ingredient-uses").append("<ul>"
                                            + "<a class='ingredient' href='/recipe/"
                                            + recipe.slug
                                            + "'>"
                                            + recipe.name
                                            + "</a><span class='details'>"
                                            + (base.ingredients[index].amount ? base.ingredients[index].amount : base.ingredients[index].label) 
                                            + "</span></ul>");
      });


      $("#ingredient-overlay").css('visibility','visible').hide().fadeIn();
    }
  });
}

$("body").on("click", ".ingredient-link", function(e) {
  href = $(this).attr("href");
  loadIngredient(href);
  e.preventDefault();
});