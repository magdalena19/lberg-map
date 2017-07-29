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

// CUSTOM CODE
//= require ./page_specific/maps/show/_map_overlays
//= require ./responsive
//= require ./history
//= require ./wysiwig_editor
//= require ./bootstrap_misc
//= require ./category_suggestions
//= require ./modals
//= require ./footer

jQuery(function() {
  jQuery('#flash-messages').delay(4000).fadeOut(800);
  jQuery('.dropdown-toggle').dropdown();
});
