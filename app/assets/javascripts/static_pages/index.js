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

  // RESPONSIVE HEIGHT
  jQuery(window).resize(function(){
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', - (navbarHeight + 15));
  }).resize();
});
