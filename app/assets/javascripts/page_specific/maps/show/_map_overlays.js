jQuery(function() {
  var placesListPanel = jQuery('.places-list-panel');
  var placesListPanelToggle = jQuery('.toggle-panel');
  var mapControls = jQuery('.map-controls-container');

  // Disable default password modal click behaviour
  $('.map-password-dialog').modal({
    backdrop: 'static',
    keyboard: false
  })

  hideMapElements = function() {
    placesListPanel.hide();
    mapControls.hide();
    hideFilterField();
  };

  showMapElements = function() {
    showFilterField();
    // showMapControls();
    mapControls.hasClass('active') && showMapControls();
    placesListPanel.hasClass('active') && showSidepanel();

    // if (window.outerWidth > 600) {
    //   jQuery('.toggle-panel').trigger('click');
    // }
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
    placesListPanelToggle.find('.glyphicon').removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-left');
    placesListPanel.addClass('active').show();
    placesListPanelToggle.show();
    placesListPanelToggle.css('left', placesListPanel.outerWidth());
    if (window.outerWidth <= 600) {
      hideMapControls();
    }
  };

  hideSidepanel = function() {
    placesListPanelToggle.find('.glyphicon').removeClass('glyphicon-chevron-left').addClass('glyphicon-chevron-right');
    placesListPanel.removeClass('active').hide();
    placesListPanelToggle.css('left', 0);
    showMapControls();
  };
});
