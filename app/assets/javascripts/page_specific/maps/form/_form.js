//= require ./_tagging_maintainance

// MAP FORM FUNCTIONALITY
jQuery(function() {

  // Password
  jQuery('.password-checkbox').on('click', 'input', function() {
    var checkbox = jQuery(this)[0];
    var passwordField = jQuery('#map_password');
    var passwordConfirmationField = jQuery('#map_password_confirmation');

    if (checkbox.checked) {
      passwordField.attr('disabled', false).attr('placeholder', '•••••')
      passwordConfirmationField.attr('disabled', false).attr('placeholder', '•••••')
    } else {
      passwordField.attr('disabled', true).val('').attr('placeholder', '')
      passwordConfirmationField.attr('disabled', true).val('').attr('placeholder', '')
    }
  });

  // Toggle translation engine selection if auto-translate checked
  jQuery('#map_auto_translate').on('click', function() {
    var checked = $(this).is(':checked');
    if (checked) {
      jQuery('#map_translation_engine').show(350);
    } else {
      jQuery('#map_translation_engine').hide(350);
    }
  });

  // Toggle publication settings if publication checked
  function toggleIfChecked(checkbox, divToToggle) {
    var checked = jQuery(checkbox).is(':checked');
    if (checked) {
      jQuery(divToToggle).show(350);
    } else {
      jQuery(divToToggle).hide(350);
    }
  }

  jQuery('#map_is_public').on('click', function() {
    toggleIfChecked('#map_is_public', '.map-public-settings')
  });

  // Toggle publication settings initially
  toggleIfChecked('#map_is_public', '.map-public-settings');

  // Generate public token
  function camelize(string) {
    return string.toLowerCase().split(' ').join('_');
  }

  jQuery('#map_title').on('input', function() {
    title = jQuery(this).val();
    var public_token_input = jQuery('#map_public_token');
    public_token_input.val(camelize(title)).trigger('change');
  });
})
