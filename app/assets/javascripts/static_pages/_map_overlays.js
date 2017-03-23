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
