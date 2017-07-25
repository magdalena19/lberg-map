// All code related to page responsiveness
jQuery(function() {
  // RESPONSIVE HEIGHT
  jQuery(window).resize(function() {
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', -(navbarHeight + 15));
    jQuery('.main-container').css('margin-top', navbarHeight + 15);
  }).resize();
});
