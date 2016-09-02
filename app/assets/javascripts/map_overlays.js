slidePanelVisible = false;

// fired when window get resized (application.js)
balanceSidebar = function() {
  jQuery('.announcements-panel').height(jQuery(window).height() - jQuery('.last-points-panel').height() - 150);
  var cumHeight = 0;
  var sidebarHeight = jQuery('.sidebar').innerHeight();
  jQuery(function() {
    jQuery.each(jQuery('.announcement-news'), function() {
      var obj = jQuery(this);
      cumHeight += obj.outerHeight() + 20;
      if (cumHeight > jQuery('.announcements-panel').height()) {
        obj.hide();
      }
      else {
        obj.show();
      };
    });
  });

  if (jQuery(window).height() < 500 || jQuery(window).width() < 800) {
    jQuery('.sidebar').css('opacity', '0');
    jQuery('.show-sidebar-container').css('opacity', '0');
  } else {
    if (slidePanelVisible == false) {
      jQuery('.sidebar').css('opacity', '100');
      jQuery('.show-sidebar-container').css('opacity', '100');
    };
  };
};

jQuery(function() {
  // ANNOUNCEMENTS
  jQuery('.open-sidebar').click(function(){
    jQuery('.show-sidebar-container').hide(500);
    jQuery('.sidebar').show(500);
  });

  jQuery('.close-sidebar').click(function(){
    jQuery('.show-sidebar-container').show(500);
    jQuery('.sidebar').hide(500);
  });
  jQuery('.show-sidebar-container').hide();

  jQuery.each(jQuery('.announcement'), function() {
    var angle = Math.random() * 3 - 2;
    jQuery(this).css('transform', 'rotate(' + angle + 'deg)');
  });

  // SLIDE PANELS
  var slidePanels = jQuery('.slidepanel');
  var sideBar = jQuery('.sidebar');

  slidePanels.each(function() {
    var panel = jQuery(this);
    panel.bind('open', function() {
      panel.animate({bottom: '10'}, 300);
      panel.addClass('slidx-open');
      jQuery('.control-container').hide();
      jQuery('.navbar-dropdown').hide();
      jQuery('.sidebar').css('opacity', '0');
      jQuery('.show-sidebar-container').css('opacity', '0');
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
    if (!panel.hasClass('slidx-open')) {
      panel.trigger('open');
    }
    else {
      panel.trigger('close');
    }
  });

  jQuery('.hide-slidepanel').click(function() {
    closeAllPanels();
  });

});
