jQuery(function() {
  if (jQuery('.sidebar').is(':visible')) {
    jQuery('.open-sidebar').hide();
  }

  jQuery('.open-sidebar').click(function(){
    jQuery('.open-sidebar').hide(500);
    jQuery('.sidebar').show(500);
  });

  jQuery('.close-sidebar').click(function(){
    jQuery('.open-sidebar').show(500);
    jQuery('.sidebar').hide(500);
  });

  var balanceSidebar = function() {
    var cumHeight = 0;
    var sidebarHeight = $('.sidebar').innerHeight();

    // Throttle size of visible announcements and resize panel accordingly
    jQuery(function() {
      var announcementsPanel = $('.announcements-panel');
      var finalPanelHeight = 0;

      $.each($('.announcement-news'), function(index) {
        $(this).show();
        cumHeight += $(this).outerHeight(true);
        if (cumHeight > announcementsPanel.height()) {
          $(this).hide();
        }
        else {
          var a = Math.random() * 4 - 2;
          jQuery(this).css('transform', 'rotate(' + a + 'deg)');
        }
      });

    });
  };

  jQuery(window).resize(function(){
    balanceSidebar();
  });
});
