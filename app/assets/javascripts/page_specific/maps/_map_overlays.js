jQuery(function() {

  hideMapElements = function() {
    jQuery('.places-list-panel').hide();
    jQuery('.control-container').hide();
  };

  showMapElements = function() {
    jQuery('.places-list-panel').fadeIn();
    jQuery('.control-container').show();
  };

  hideNavbarElements = function() {
    jQuery('.navbar-dropdown').hide();
    jQuery('.navbar-button').hide();
    jQuery('.navbar-toggle').css('opacity', 0);
  };

  showNavbarElements = function() {
    jQuery('.navbar-dropdown').show();
    jQuery('.navbar-button').show();
    jQuery('.navbar-toggle').css('opacity', 100);
  };

  var mapControls = jQuery('.map-controls-container');
  var panel = jQuery('.places-list-panel');
  var toggle = jQuery('.toggle-panel');
  
  showSidepanel = function() {
    toggle.find('.glyphicon').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-left');
    panel.show();
    toggle.show();
    toggle.css('left', panel.outerWidth());
    if (window.outerWidth <= 400) {
      mapControls.hide();
    }
  };

  hideSidepanel = function() {
    toggle.find('.glyphicon').removeClass('glyphicon-chevron-left').addClass('glyphicon-chevron-right');
    panel.hide();
    toggle.css('left', 0);
    mapControls.show();
  };
});
