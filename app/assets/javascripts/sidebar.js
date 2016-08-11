jQuery(function() {
  jQuery('.open-sidebar').click(function(){
    jQuery('.open-sidebar').hide(500);
    jQuery('.sidebar').show(500);
  });

  jQuery('.close-sidebar').click(function(){
    jQuery('.open-sidebar').show(500);
    jQuery('.sidebar').hide(500);
  });

  // fired when window get resized (application.js)
  balanceSidebar = function() {
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
        }
      });
    });
    if (jQuery(window).height() < 500 || jQuery(window).width() < 800) {
      jQuery('.sidebar').hide();
      jQuery('.show-sidebar-container').hide();
    } else {
      jQuery('.sidebar').show();
      jQuery('.show-sidebar-container').show();
    };

    if (jQuery('.sidebar').is(':visible')) {
      jQuery('.open-sidebar').hide();
    }
  };

  jQuery.each(jQuery('.announcement'), function() {
    var angle = Math.random() * 3 - 2;
    jQuery(this).css('transform', 'rotate(' + angle + 'deg)');
  });
});
