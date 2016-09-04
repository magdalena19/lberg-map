jQuery(function() {
  jQuery('.switch-description-view').click(function() {
    if (jQuery('.description-diff').is(':visible')) {
      jQuery('.description-diff').hide();
      jQuery('.description').show();
      jQuery('.switch-description-view').css('opacity', '0.5');
    } else {
      jQuery('.description-diff').show();
      jQuery('.description').hide();
      jQuery('.switch-description-view').css('opacity', '1');
    };
  });
});
