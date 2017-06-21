// MAP FORM FUNCTIONALITY

jQuery(function() {
  // Password
  jQuery('.password-checkbox').on('click', 'input', function() {
    var checkbox = jQuery(this)[0];
    var passwordField = jQuery('#map_password');
    var passwordConfirmationField = jQuery('#map_password_confirmation');

    if (checkbox.checked) {
      passwordField.
      attr('disabled', false).
      attr('placeholder', '•••••');
      passwordConfirmationField.
      attr('disabled', false).
      attr('placeholder', '•••••');
    } else {
      passwordField.
      attr('disabled', true).
      val('').
      attr('placeholder', '');
      passwordConfirmationField.
      attr('disabled', true).
      val('').
      attr('placeholder', '');
    }
  });

  function toggleIfChecked(checkbox_id, div_to_toggle) {
    jQuery(checkbox_id).on('click', function(){
      var checked = $(this).is(':checked');
      if (checked) {
        jQuery(div_to_toggle).show(350);
      } else {
        jQuery(div_to_toggle).hide(350);
      }
    });
  }

  toggleIfChecked('#map_auto_translate', '#map_translation_engine');

  jQuery('#map_is_public').on('click', function() {
    var checked = jQuery(this).is(':checked');
    if (checked) {
      jQuery('.map-public-settings').show(350);
    } else {
      jQuery('.map-public-settings').hide(350);
    }
  });

  // generate public token
  function camelize(string) {
    return string.toLowerCase().split(' ').join('_');
  }

  jQuery('#map_title').on('input', function() {
    title = jQuery(this).val();
    var public_token_input = jQuery('#map_public_token');
    public_token_input.val(camelize(title)).trigger('change');
  });
});