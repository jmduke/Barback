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