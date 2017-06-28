// VENDOR CODE
//= require phantomjs_polyfill-rails/bind-polyfill
//= require jquery
//= require jquery.scrollTo
//= require jquery_ujs
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

// CUSTOM CODE (non-site-specific JS)
//= require ./page_specific/maps/_map_overlays
//= require ./common/modals
//= require ./common/category_suggestion
//= require ./common/daterange_handling
//= require ./common/wysiwyg_editor
//= require ./common/contact_form
//= require ./common/footer

jQuery(function() {
  // Back button
  if (window.history.length === 1) {
    jQuery('.back-button').hide();
  }

  jQuery('.back-button').click(function() {
    window.history.back();
  });

  // Flash messages
  jQuery('#flash-messages').delay(4000).fadeOut(800);

  // Dropdown
  jQuery('.dropdown-toggle').dropdown();

  // RESPONSIVE HEIGHT
  jQuery(window).resize(function(){
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', - (navbarHeight + 15));
  }).resize();

  // Enable bootstrap tooltips
  jQuery('[data-toggle="tooltip"]').tooltip();
});
