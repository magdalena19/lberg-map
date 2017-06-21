jQuery(function() {
  var panel = jQuery('.places-list-panel');
  var toggle = jQuery('.toggle-panel');

  // Disable default password modal click behaviour
  jQuery('.map-password-dialog').modal({
    backdrop: 'static',
    keyboard: false
  });

  hideMapElements = function() {
    jQuery('.places-list-panel').hide();
    hideMapControls();
    hideFilterField();
    hideMapControls();
  };

  showMapElements = function() {
    showMapControls();
    showFilterField();
    if (window.outerWidth > 600) {
      jQuery('.places-list-panel').fadeIn();
    }
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

  hideFilterField = function() {
    jQuery('.filter-field').hide();
  };

  showFilterField = function() {
    jQuery('.filter-field').show();
  };

  hideMapTrays = function() {
    jQuery('.right-sidebar-tray').hide();
  };

  hideMapControls = function() {
    jQuery('.map-controls-container').hide();
    jQuery('.right-sidebar-tray').hide();
  };

  showMapControls = function() {
    jQuery('.map-controls-container').show();
  };

  hideAddressSearchBar = function() {
    jQuery('.leaflet-control').remove();
    jQuery('.fade-background').hide();
  };

  showAddressSearchBar = function() {
    var leaflet_control = jQuery('.leaflet-control');
    leaflet_control.remove();
    jQuery('.address-search-bar-container').append(leaflet_control);
    jQuery('.fade-background').show();
  }

  showSidepanel = function() {
    toggle.find('.glyphicon').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-left');
    panel.show();
    toggle.show();
    toggle.css('left', panel.outerWidth());
    if (window.outerWidth <= 600) {
      hideMapControls();
    }
  };

  hideSidepanel = function() {
    toggle.find('.glyphicon').removeClass('glyphicon-chevron-left').addClass('glyphicon-chevron-right');
    panel.hide();
    toggle.css('left', 0);
    showMapControls();
  };
});
