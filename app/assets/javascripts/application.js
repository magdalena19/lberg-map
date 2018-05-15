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

  // time for music
  var logoClickCounter = 0;
  jQuery('.ratmap-logo').click(function() {
    var logo = jQuery(this);
    var borderStyle = '4px solid #79C682';
    logoClickCounter += 1;
    switch (logoClickCounter) {
      case 7:
        logo.css('border-radius', '10px');
        logo.css('border-top', borderStyle);
        break;
      case 8:
        logo.css('border-right', borderStyle);
        break;
      case 9:
        logo.css('border-bottom', borderStyle);
        break;
      case 10:
        logo.css('border-left', borderStyle);
        new Audio('/theme.mp3').play();
    }
  });
});