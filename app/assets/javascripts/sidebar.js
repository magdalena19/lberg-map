jQuery(function(){
  // SIDEBAR

  closeSidebar = function() {
    jQuery('.open-sidebar').show();
    jQuery('.sidebar').hide();
  };

  showSidebar = function() {
    jQuery('.open-sidebar').hide();
    jQuery('.sidebar').show();
  };

  if (jQuery('.sidebar').is(':visible')) {
    jQuery('.open-sidebar').hide();
  }

  jQuery('.open-sidebar').click(function(){
    showSidebar();
  });

  jQuery('.close-sidebar').click(function(){
    closeSidebar();
  });

  // rotate announcement post-its
  $('.announcement').each(function() {
    var a = Math.random() * 6 - 2;
    $(this).css('transform', 'rotate(' + a + 'deg)');
  });
});
