//= require phantomjs_polyfill-rails/bind-polyfill
//= require jquery
//= require jquery.scrollTo
//= require jquery_ujs
//= require spectrum
//= require bootstrap
//= require bootstrap-sprockets
//= require bootstrap-wysihtml5
//= require awesomplete
//= require moment
//= require dataTables/jquery.dataTables
//= require dataTables.fixedHeader.min
//= require dataTables_responsive
//= require datetime-moment
//= require daterangepicker

//= require ./page_specific/maps/show/_map_overlays
//= require wysiwyg
//= require tagging
//= require place_form
//= require navbar
//= require footer
//= require modals
//= require landing_page

jQuery(function() {
  if (window.history.length === 1) {
    jQuery('.back-button').hide();
  }

  jQuery('#flash-messages').delay(4000).fadeOut(800);

  jQuery('.dropdown-toggle').dropdown();

  jQuery('.back-button').click(function() {
    window.history.back();
  });

  jQuery(window).resize(function() {
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.main-container').css('margin-top', navbarHeight + 15);
  }).resize();

  // RESPONSIVE HEIGHT
  jQuery(window).resize(function() {
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', -(navbarHeight + 15));
  }).resize();

  // Enable bootstrap tooltips
  jQuery('[data-toggle="tooltip"]').tooltip();
});