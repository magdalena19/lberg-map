//= require leaflet
//= require static_pages/_map_base

jQuery(function() {
  jQuery('#map').each(function() {
    addEsriMap();
  });

  // HIDE NAVBAR ELEMENTS
  jQuery('.navbar-dropdown').hide();
  jQuery('.navbar-button').hide();
  jQuery('.navbar-toggle').css('opacity', 0);
});
