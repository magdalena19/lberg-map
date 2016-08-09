jQuery(function(){
  // SIDEBAR
  if (jQuery('.sidebar').is(':visible')) {
    jQuery('.open-sidebar').hide();
  }

  jQuery('.open-sidebar').click(function(){
    jQuery('.open-sidebar').hide();
    jQuery('.sidebar').show();
  });

  jQuery('.close-sidebar').click(function(){
    jQuery('.open-sidebar').show();
    jQuery('.sidebar').hide();
  });

  // rotate announcement post-its
  $('.announcement').each(function() {
    var a = Math.random() * 6 - 2;
    $(this).css('transform', 'rotate(' + a + 'deg)');
  });
});
