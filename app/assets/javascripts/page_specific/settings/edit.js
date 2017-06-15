jQuery(function() {
  function checkCaptchaStatus(captcha_system) {
    // Notify about status
    jQuery('.notification').find('.spinner-icon').show();
    jQuery('.notification').find('.status-icon').hide();
    jQuery('.notification').find('.status-text').text(window.fetch_captcha_translation);

    // Fetch status
    jQuery.when(
      jQuery.ajax({
        url: '/admin/settings/captcha_system_status',
        data: { captcha_system: 'simple_captcha' }
      })
    ).then( function(data) {
      var notification = jQuery('.notification');
      notification.find('.spinner-icon').hide();

      if ( data.status_code === 'error' ) {
        notification.find('.error-icon').show();
        notification.addClass('error');
      } else {
        notification.find('.success-icon').show();
        notification.addClass('success');
      }
      notification.find('.status-text').text(data.status_message);
    });
  }

  checkCaptchaStatus('simple_captcha');

  jQuery('#admin_setting_captcha_system').on('change', function() {
    checkCaptchaStatus(jQuery(this).val());
  })

});
