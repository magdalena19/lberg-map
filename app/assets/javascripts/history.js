// History
jQuery(function() {
  if (window.history.length === 1) {
    jQuery('.back-button').hide();
  }

  jQuery('.back-button').click(function() {
    window.history.back();
  });
});
