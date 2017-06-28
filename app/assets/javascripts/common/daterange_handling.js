jQuery(function() {
  // Place events
  var picker = function(div, with_end_date) {
    div.daterangepicker({
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
    picker(
      jQuery('#place_start_date'),
      jQuery('#set_end_date').is(':checked')
    );
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

  picker(
    jQuery('#search-date-input'),
    true
  );
});