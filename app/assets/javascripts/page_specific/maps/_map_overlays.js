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
  
  var panel = jQuery('.places-list-accordion-container');
  var toggle = jQuery('.toggle-panel');
  var zoom_container = jQuery('.zoom-container');
  var add_place_button = jQuery('.add-place-button');

  showSidepanel = function() {
    toggle.find('.glyphicon').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-left');
    panel.show();
    toggle.show();
    toggle.css('left', panel.outerWidth());
  };
  
  hideSidepanel = function() {
    toggle.find('.glyphicon').removeClass('glyphicon-chevron-left').addClass('glyphicon-chevron-right');
    panel.hide();
    toggle.css('left', 0);
    toggle.css('z-index', 9999);
  };

  // Close slidePanels on Escape keypress
  window.addEventListener("keydown", function (event) {
    if (event.defaultPrevented) {
      return; // Should do nothing if the key event was already consumed.
    }

    switch (event.key) {
      case "Escape":
        // do anything
      break;
      default:
      return; // Quit when this doesn't handle the key event.
    }

    // Consume the event to avoid it being handled twice
    event.preventDefault();
  }, true);
});
