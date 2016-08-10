jQuery(function() {
  // SIDEBAR

  closeSidebar = function() {
    jQuery('.open-sidebar').show(500);
    jQuery('.sidebar').hide(500);
  };

  showSidebar = function() {
    jQuery('.open-sidebar').hide(500);
    jQuery('.sidebar').show(500);
  };

  // Prevent displaying button and sidebar at the same time on page landing
  if (jQuery('.sidebar').is(':visible')) {
    jQuery('.open-sidebar').hide();
  }

  jQuery('.open-sidebar').click(function(){
    showSidebar();
  });

  jQuery('.close-sidebar').click(function(){
    closeSidebar();
  });
});
