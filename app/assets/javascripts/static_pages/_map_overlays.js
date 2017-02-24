jQuery(function() {

  var slidePanels = jQuery('.slidepanel');
  var sideBar = jQuery('.sidebar');
  var showSidebarContainer = jQuery('.show-sidebar-container');

  slidePanelVisible = false;

  hideMapElements = function() {
    jQuery('.places-list-panel').hide();
    jQuery('.control-container').hide();
    sideBar.css('z-index', '-1');
    showSidebarContainer.css('z-index', '-1');
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

  // SLIDE PANELS
  slidePanels.each(function() {
    var panel = jQuery(this);
    panel.bind('open', function() {
      closeAllPanels();
      hideNavbarElements();
      hideMapElements();
      panel.animate({bottom: '10'}, 300);
      panel.addClass('slidx-open');
      slidePanelVisible = true;
    });
    panel.bind('close', function() {
      showNavbarElements();
      showMapElements();
      panel.css('bottom', '-' + panel.outerHeight() + 'px');
      panel.removeClass('slidx-open');
      slidePanelVisible = false;
    });

    closeAllPanels = function() {
      slidePanels.each(function() {
        jQuery(this).trigger('close');
      });
    };
  });

  // fired when window get resized (application.js)
  resizePanels = function() {
    slidePanels.each(function() {
      var panel = jQuery(this);
      var height = jQuery(window).height() - 160;
      var width = jQuery(window).width() - 20;
      panel.find('.content').css('max-height', height + 'px');
      panel.width(width);
      if (!panel.hasClass('slidx-open')) {
        panel.css('bottom', '-' + panel.outerHeight() + 'px');
      }
    });
  };

  jQuery('.slidepanel-button').click(function() {
    var panelName = jQuery(this).attr('slidepanel');
    var panel = jQuery('.' + panelName);
    panel.trigger('open');
  });

  jQuery('.hide-slidepanel').click(function() {
    closeAllPanels();
  });

  // Close slidePanels when clicking on map
  jQuery('#map').click(function() {
    closeAllPanels();
  });

  // Close slidePanels on Escape keypress
  window.addEventListener("keydown", function (event) {
    if (event.defaultPrevented) {
      return; // Should do nothing if the key event was already consumed.
    }

    switch (event.key) {
      case "Escape":
        closeAllPanels();
      break;
      default:
      return; // Quit when this doesn't handle the key event.
    }

    // Consume the event to avoid it being handled twice
    event.preventDefault();
  }, true);
});
