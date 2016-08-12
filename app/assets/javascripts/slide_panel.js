jQuery(function() {
  var slidePanels = jQuery('.slidepanel');
  var sideBar = jQuery('.sidebar');

  slidePanels.each(function() {
    var panel = jQuery(this);
    panel.bind('open', function() {
      closeAllPanels();
      panel.animate({bottom: '10'}, 300);
      panel.addClass('slidx-open');
      jQuery('.control-container').hide();
      jQuery('.navbar-dropdown').hide();
      jQuery('.open-sidebar').show(500);
      jQuery('.sidebar').hide(500);
    });
    panel.bind('close', function() {
      panel.css('bottom', '-' + panel.outerHeight() + 'px');
      panel.removeClass('slidx-open');
      jQuery('.control-container').show();
      jQuery('.navbar-dropdown').show();
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
