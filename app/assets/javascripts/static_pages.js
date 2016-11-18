jQuery(function(){
  jQuery('.about_section').hover(function(){
    $(this).css('color', 'rgb(0, 0, 0)');
  },function(){
    $(this).css('color', 'rgb(143, 143, 143)');
  });

  // Deactivate "send copy to sender" option if no email address is present
  $('#message_sender_email').on('input', function(val){
    var current_value = $(this).val();
    if (current_value != '') {
      $('.email_reply').show(350);
    } else {
      $('.email_reply').hide(350);
    }
  })
});
