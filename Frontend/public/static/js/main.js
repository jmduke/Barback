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