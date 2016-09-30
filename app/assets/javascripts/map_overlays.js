jQuery(function() {

  var slidePanels = jQuery('.slidepanel');
  var sideBar = jQuery('.sidebar');
  var showSidebarContainer = jQuery('.show-sidebar-container');

  slidePanelVisible = false;

  // fired when window get resized (application.js)
  balanceSidebar = function() {
    jQuery('.announcements-panel').height(jQuery(window).height() - jQuery('.last-points-panel').height() - 150);
    var cumHeight = 0;
    var sidebarHeight = sideBar.innerHeight();
    jQuery(function() {
      jQuery.each(jQuery('.announcement-news'), function() {
        var obj = jQuery(this);
        cumHeight += obj.outerHeight() + 20;
        if (cumHeight > jQuery('.announcements-panel').height()) {
          obj.hide();
        }
        else {
          obj.show();
        }
      });
    });

    if (jQuery(window).height() < 500 || jQuery(window).width() < 800) {
      sideBar.css('z-index', '-1');
      showSidebarContainer.css('z-index', '-1');
    } else {
      if (slidePanelVisible === false) {
        sideBar.css('z-index', '9999');
        showSidebarContainer.css('z-index', '9999');
      }
    }
  };

  // ANNOUNCEMENTS
  jQuery('.open-sidebar').click(function(){
    showSidebarContainer.hide(500);
    sideBar.show(500);
    balanceSidebar();
  });

  jQuery('.close-sidebar').click(function(){
    showSidebarContainer.show(500);
    sideBar.hide(500);
  });
  showSidebarContainer.hide();

  jQuery.each(jQuery('.announcement'), function() {
    var angle = Math.random() * 3 - 2;
    jQuery(this).css('transform', 'rotate(' + angle + 'deg)');
  });

  // SLIDE PANELS
  slidePanels.each(function() {
    var panel = jQuery(this);
    panel.bind('open', function() {
      closeAllPanels();
      panel.animate({bottom: '10'}, 300);
      panel.addClass('slidx-open');
      jQuery('.control-container').hide();
      jQuery('.navbar-dropdown').hide();
      sideBar.css('z-index', '-1');
      showSidebarContainer.css('z-index', '-1');
      slidePanelVisible = true;
    });
    panel.bind('close', function() {
      panel.css('bottom', '-' + panel.outerHeight() + 'px');
      panel.removeClass('slidx-open');
      jQuery('.control-container').show();
      jQuery('.navbar-dropdown').show();
      slidePanelVisible = false;
    });

    closeAllPanels = function() {
      slidePanels.each(function() {
        jQuery(this).trigger('close');
      });
      balanceSidebar();
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
