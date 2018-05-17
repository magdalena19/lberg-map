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

  // Toggle publication settings if publication checked
  function toggleIfChecked(checkbox, divToToggle) {
    var checked = jQuery(checkbox).is(':checked');
    if (checked) {
      jQuery(divToToggle).show(350);
      assignPublicToken();
    } else {
      jQuery(divToToggle).hide(350);
      clearPublicTokenField();
    }
  }

  function assignPublicToken(){
    $('#map_public_token').val(window.public_token_proposal).trigger('change');
  }

  function clearPublicTokenField(){
    $('#map_public_token').val(null).trigger('change');
  }

  jQuery('#map_is_public').on('click', function() {
    toggleIfChecked('#map_is_public', '.map-public-settings')
  });

  // Toggle publication settings initially
  toggleIfChecked('#map_is_public', '.map-public-settings');
})
