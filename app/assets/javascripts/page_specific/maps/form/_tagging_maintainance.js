// MAP FORM FUNCTIONALITY

//= require ./_tagging_maintainance
jQuery(function() {
  // TAGGING MAINTAINANCE

  //--- INDEX tags
  // TODO this is all very complicated... embrace React sooner or later... :/
  function receiveTags() {
    jQuery.ajax({
      url: '/' + window.map_token + '/categories',
      method: 'GET',
      data: { map_token: window.map_token },
      context: this,
      success: function(tagList) {
        if (tagList.length > 0) populateTags(tagList);
      },
      error: function(e) {
        console.log(e);
      }
    })
  }

  // TODO does not assign data attributes at all... oO
  function populateTags(tags) {
    var tagList = jQuery('.tag-list');
    var categoryTranslationsTemplate = tagList.find('#category-form-template');

    // Traverse through tags and assign proper attributes to dynamically generated form elements
    jQuery.each(tags, function(index, tag) {
      // Clone empty template
      var categoryTranslations = categoryTranslationsTemplate.clone().removeClass('template');
      var currentTagTranslation = tag['name_' + window.current_locale];
      var categoryInputs = categoryTranslations.find('input');

      // Label: Translation of category under current locale
      categoryTranslations.find('.current-tag-translation').text(currentTagTranslation);
      // Category count: Occurences through out all POIs on map
      categoryTranslations.find('.category-count').html('<i>(' + tag.poiCount + ' POIs)</i>');

      // Fill input fields with matched values from tag object
      jQuery.each(categoryInputs, function(index, input) {
        var input = jQuery(input);
        var localeKey = input.data('attribute'); // Get key 'name_<locale>' as input data attr
        var categoryName = tag[localeKey];

        input.val(categoryName); // Assign value from tag object

        // Add proper classes
        input.addClass('category-' + tag.categoryId); // TODO need that?
        if (categoryName === '' || undefined) input.addClass('alert alert-danger');

        // Add proper data attributes
        input.
          attr('data-category-id', tag.categoryId).
          attr('data-original-value', categoryName);
      });

      // Assign Button attributes
      updateButton = categoryTranslations.find('.update-tag-button');
      deleteButton = categoryTranslations.find('.delete-tag-button');

      updateButton.attr('data-category-id', tag.categoryId).attr('disabled', 'disabled');
      deleteButton.attr('data-category-id', tag.categoryId);

      // Append snippet to category list
      tagList.append(categoryTranslations);
    });
  }

  if (window.map_token != "") {
    receiveTags();
  }

  //--- CREATE tags
  jQuery('.toggle-create-tag-modal').on('click', function() {
    jQuery('.create-map-tags-modal').modal('show');
  });

  // Disable / enable button if inputs empty
  jQuery('.create-map-tags-modal input').on('keyup', function() {
    var inputs = jQuery(this).closest('.create-map-tags-modal').find('input');
    var submitButton = jQuery('.modal-content .create-tag-button');

    var inputsFilled = jQuery.map(inputs, function(input) {
      return jQuery(input).val() !== '' || undefined;
    });

    if (inputsFilled.includes(true)) {
      submitButton.removeAttr('disabled')
    } else {
      submitButton.attr('disabled', 'disabled')
    }
  });

  jQuery('.modal-content .create-tag-button').on('click', function() {
    // Grab all input fields
    var inputs = jQuery('.modal-content .modal-body').find('input');

    // Generate new Tag data JSON
    var newTagData = {};
    jQuery.each(inputs, function(index, input) {
      var attr = jQuery(input).data('attribute');
      var value = jQuery(input).val();

      newTagData[attr] = value;
    })

    // POST new Tag
    jQuery.ajax({
      url: '/' + window.map_token + '/categories',
      method: 'POST',
      data: {
        category: newTagData
      },
      context: this,
      success: function(tag) {
        jQuery('.create-map-tags-modal').modal('hide');
        populateTags([tag]);
      },
      error: function(e) {
        console.log(e);
      }
    })
  });


  //--- UPDATE tag names
  jQuery('.tag-list').on('click', '.update-tag-button', function() {
    var updateButton = jQuery(this);
    var id = updateButton.data('categoryId');

    // Gather new values
    new_vals = {
      id: id,
      category: {}
    };

    jQuery('.category-' + id).each(function() {
      var attribute = jQuery(this).data('attribute');
      var value = jQuery(this).val();

      new_vals.category[attribute] = value
    });

    // Send ajax request with new values
    jQuery.ajax({
      url: '/' + window.map_token + '/categories/' + id,
      method: 'PATCH',
      data: new_vals,
      context: this,
      success: function(response) {
        // Disable update button
        updateButton.attr('disabled', 'disabled');
      },
      error: function(e) {
        // Find inputs
        var inputs = jQuery(this).closest('.category-translations').find('input');

        // Restore original values
        inputs.each(function() {
          attr = jQuery(this).data('original-value'); // Grab attribute name of input field in scope
          jQuery(this).val(response[attr]); // Match input attribute with response object and assign value
        });

        // TODO Flash message
      }
    });
  });

  // TODO little slow...
  // Enable / Disable update button onChange category input
  jQuery('.tag-list').on('keyup', 'input', function() {
    var currentInput = jQuery(this);
    var inputs = jQuery(this).closest('.category-translations').find('input');
    var updateButton = jQuery(this).closest('.category-translations').find('.update-tag-button');

    // Alert if current input is empty
    if (currentInput.val() === '') {
      currentInput.addClass('alert alert-danger');
    } else {
      currentInput.removeClass('alert alert-danger');
    }

    // Traverse and query all inputs for changes
    var inputsChanged = jQuery.map(inputs, function(input) {
      return jQuery(input).val() !== jQuery(input).data('original-value')
    });

    // Enable / disable update button if any input has changes
    if (inputsChanged.includes(true)) {
      updateButton.removeAttr('disabled')
    } else {
      updateButton.attr('disabled', 'disabled')
    }
  });


  //--- DELETE tags
  jQuery('.tag-list').on('click', '.delete-tag-button', function() {
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
        }
      });
    }
  });
})
