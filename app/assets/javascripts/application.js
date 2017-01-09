// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables_responsive
//= require jquery-ui
//= require bootstrap
//= require bootstrap-sprockets
//= require bootstrap-wysihtml5
//= require leaflet
//= require leaflet.markercluster
//= require_tree .

jQuery(function() {
  if (window.history.length === 1) {
    jQuery('.back-button').hide();
  }

  jQuery('#flash-messages').delay(8000).fadeOut(800);
  jQuery('.dropdown-toggle').dropdown();
  jQuery('.back-button').click(function() {
    window.history.back();
  });

  // RESPONSIVE HEIGHT
  jQuery(window).resize(function(){
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', - (navbarHeight + 15));
    jQuery('.confirmation-button-container').css('top', navbarHeight + 3);
    jQuery('.main-container').css('margin-top', navbarHeight + 15);
    balanceSidebar();
    resizePanels();
  }).resize();

  jQuery('.locale-slidepanel').trigger('open');

  jQuery('.wysihtml5').each(function(i, elem) {
    $(elem).wysihtml5({
      toolbar: {
        'font-styles': false,
        'emphasis': true,
        'lists': true,
        'html': true,
        'link': true,
        'image': false,
        'color': false
      }
    });
  });
});
