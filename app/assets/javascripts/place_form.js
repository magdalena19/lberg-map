jQuery(function() {
  jQuery('.place-modal').on('show.bs.modal', function() {
    initWysiwyg();
    initCategoryInput(window.categories);

    // Place events
    var picker = function(div, with_end_date) {
      div.daterangepicker({
        "startDate": moment(window.start_date, 'YYYY-MM-DD hh:mm:ss').utc(),
        "endDate": moment(window.end_date, 'YYYY-MM-DD hh:mm:ss').utc(),
        "singleDatePicker": !with_end_date,
        "showDropdowns": true,
        "showWeekNumbers": true,
        "timePicker": true,
        "timePicker24Hour": true,
        "timePickerIncrement": 15,
        "linkedCalendars": false,
        "showCustomRangeLabel": false,
        "locale": {
          format: 'DD.MM.YYYY h:mm A'
        }
      });
    };

    jQuery('#is_place').on('click', function() {
      jQuery('#place_start_date').prop('disabled', true);
      jQuery('#set_end_date').prop('disabled', true);
    });

    jQuery('#is_event').on('click', function() {
      jQuery('#place_start_date').prop('disabled', false);
      jQuery('#set_end_date').prop('disabled', false);
    });

    jQuery('#set_end_date').on('click', function() {
      var with_end_date = jQuery(this).prop('checked');
      var date_input = jQuery('#place_start_date');
      var orig_value = date_input.val();
      var start_date = orig_value.split(' - ')[0];
      var end_date = orig_value.split(' - ')[1];

      if (with_end_date === false) {
        date_input.val(start_date).trigger('change');
      } else {
        date_input.val(start_date + ' - ' + start_date).trigger('change');
      }

      picker(
        jQuery('#place_start_date'),
        with_end_date
      );
    });

    picker(jQuery('#place_start_date'), jQuery('#set_end_date').is(':checked'));

    jQuery('.contact-information-header').click(function() {
      jQuery('.contact-information').toggle();
      jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom');
      jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-top');
    });

    jQuery('.date-information-header').click(function() {
      jQuery('.date-information').toggle();
      jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom');
      jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-top');
    });

    jQuery('.description-header').click(function() {
      jQuery(this).siblings('.description-editor').toggleClass('hidden-description');
      jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom');
      jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-top');
    });

    // attributes has to be submitted via FormData objects to make multiple file upload work
    // hence we need the following manual ajax submitions overwriting the default form behavior
    // error handling and  callbacks are handled in .ajaxComplete function somewhere else
    var ajaxPost = function(url, data) {
      $.ajax({
        url: url,
        type: 'POST',
        processData: false,
        contentType: false,
        data: data,
      });
    }

    $('#new_place').on('submit', function(e){
      e.preventDefault();
      ajaxPost('/' + window.map_token + '/places', new FormData(this));
      return false; // prevents default submit
    });

    $('.edit_place').on('submit', function(e){
      e.preventDefault();
      var placeId = jQuery(this).attr('place_id');
      ajaxPost('/' + window.map_token + '/places/' + placeId, new FormData(this));
      return false; // prevents default submit
    });

    jQuery('.destroy-image').click(function() {
      var $parent = jQuery(this).parents('.image-row');
      $parent.find('.destroy-checkbox').prop('checked', true);
      $parent.hide();
    });
  });
});
