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
  jQuery('#map_is_public').on('click', function() {
    var checked = jQuery(this).is(':checked');
    if (checked) {
      jQuery('.map-public-settings').show(350);
    } else {
      jQuery('.map-public-settings').hide(350);
    }
  })

  // Generate public token
  function camelize(string) {
    return string.toLowerCase().split(' ').join('_');
  }

  jQuery('#map_title').on('input', function() {
    title = jQuery(this).val();
    var public_token_input = jQuery('#map_public_token');
    public_token_input.val(camelize(title)).trigger('change');
  })

  // TAGGING MAINTAINANCE
  //--- DELETE tags
  jQuery('.delete-tag-button').on('click', function() {
    if (confirm(window.delete_confirmation_text)) {
      var id = jQuery(this).data('categoryId');

      // Send ajax request with new values
      jQuery.ajax({
        url: '/' + window.map_token + '/categories/' + id,
        method: 'DELETE',
        data: id,
        context: this,
        success: function() {
          jQuery(this).closest('.category-translations').fadeOut(350);
          // jQuery(this).closest('.category-translations').remove();
        }
      });
    }
  });
})
