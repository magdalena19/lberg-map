jQuery(function() {
  var placesListPanel = jQuery('.places-list-panel');
  var placesListPanelToggle = jQuery('.toggle-panel');
  var mapControls = jQuery('.map-controls-container');

  // Disable default password modal click behaviour
  jQuery('.map-password-dialog').modal({
    backdrop: 'static',
    keyboard: false
  })

  hideMapElements = function() {
    placesListPanel.hide();
    placesListPanelToggle.hide();
    mapControls.hide();
    hideFilterField();
    hideMapTrays();
  };

  showMapElements = function() {
    showFilterField();
    placesListPanelToggle.show();
    mapControls.hasClass('active') && showMapControls();
    placesListPanel.hasClass('active') && showPlacesListPanel();
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
    mapControls.removeClass('active').hide();
    jQuery('.right-sidebar-tray').hide();
  };

  showMapControls = function() {
    mapControls.addClass('active').show();
  };

  hideAddressSearchBar = function() {
    jQuery('.leaflet-control-geocoder').remove();
    jQuery('.fade-background').hide();
    placesListPanelToggle.show();
  };

  showAddressSearchBar = function() {
    var leaflet_control = jQuery('.leaflet-control-geocoder');
    leaflet_control.remove();
    jQuery('.address-search-bar-container').append(leaflet_control);
    jQuery('.leaflet-control-geocoder-form > input').focus();
    jQuery('.fade-background').show();
    hideMapElements();
  }

  showPlacesListPanel = function() {
    // Activate and show places list
    placesListPanel.addClass('active').show();

    // Modify switch
    placesListPanelToggle.find('.glyphicon').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-left');
    placesListPanelToggle.show();
    placesListPanelToggle.css('left', placesListPanel.outerWidth());
    if (window.innerWidth <= 600) {
      hideMapControls();
    }
  };

  hidePlacesListPanel = function() {
    placesListPanelToggle.find('.glyphicon').removeClass('glyphicon-chevron-left').addClass('glyphicon-chevron-right');
    placesListPanel.removeClass('active').hide();
    placesListPanelToggle.css('left', 0);
    showMapControls();
  };

  showMapDescription = function() {
    jQuery('.map-description-modal').modal().show();
  }
});
