// Code related to contact form (inactive at the moment)
jQuery(function() {
  // Deactivate "send copy to sender" option if no email address is present
  jQuery('#message_sender_email').on('input', function(val) {
    var currentValue = $(this).val();
    if (currentValue !== '') {
      jQuery('.email_reply').show(350);
    } else {
      jQuery('.email_reply').hide(350);
    }
  });
});
