//= require map_base

jQuery(function() {
  // Random float between
  var randomFloatBetween = function(minValue, maxValue) {
    return parseFloat(Math.min(minValue + (Math.random() * (maxValue - minValue)), maxValue).toFixed(2));
  };

  jQuery('#map').each(function() {
    var lat = randomFloatBetween(-70, 70);
    var lon = randomFloatBetween(00, 180);
    addEsriMap([lat, lon], 2);
  });

  // HIDE NAVBAR ELEMENTS
  jQuery('.navbar-dropdown').hide();
  jQuery('.navbar-button').hide();
  jQuery('.navbar-toggle').css('opacity', 0);
});
