//= require phantomjs_polyfill-rails/bind-polyfill
//= require jquery
//= require jquery_ujs
//= require jquery.scrollTo
//= require bootstrap
//= require bootstrap-sprockets
//= require bootstrap-wysihtml5
//= require awesomplete
//= require moment
//= require daterangepicker

jQuery(function() {
  if (window.history.length === 1) {
    jQuery('.back-button').hide();
  }

  jQuery('#flash-messages').delay(8000).fadeOut(800);
  jQuery('.dropdown-toggle').dropdown();
  jQuery('.back-button').click(function() {
    window.history.back();
  });

  jQuery(window).resize(function(){
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.main-container').css('margin-top', navbarHeight + 15);
  }).resize();

  // RESPONSIVE HEIGHT
  jQuery(window).resize(function(){
    var navbarHeight = jQuery('.navbar').height();
    jQuery('.map-container').height(jQuery(window).height()).css('margin-top', - (navbarHeight + 15));
  }).resize();

  // wysiwyg editor
  jQuery('.wysihtml5').each(function(i, elem) {
    $(elem).wysihtml5({
      toolbar: {
        'font-styles': false,
        'emphasis': true,
        'lists': true,
        'html': true,
        'link': true,
        'image': false,
        'color': false
      }
    });
  });

  jQuery('.description-header').click(function() {
    jQuery(this).siblings('.description-editor').toggleClass('hidden-description');
    jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-bottom');
    jQuery(this).find('.glyphicon').toggleClass('glyphicon-triangle-top');
  });

  // Deactivate "send copy to sender" option if no email address is present
  jQuery('#message_sender_email').on('input', function(val){
    var current_value = $(this).val();
    if (current_value !== '') {
      jQuery('.email_reply').show(350);
    } else {
      jQuery('.email_reply').hide(350);
    }
  })
  
  // Place events

  var picker = function() {
    var with_end_date = jQuery('#set_end_date').is(':checked');
    $('#place_start_date').daterangepicker({
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
      },
    }, function(start, end, label) {
      console.log("New date range selected: ' + start.format('YYYY-MM-DD') + ' to ' + end.format('YYYY-MM-DD') + ' (predefined range: ' + label + ')");
    });
  }

  jQuery('#place_event').on('click', function(){
    var checked = $(this).is(':checked');
    if (checked) {
      jQuery('.place_start_date').show(350);
      jQuery('.place_end_date').show(350);
      picker();
    } else {
      jQuery('.place_start_date').hide(350);
      jQuery('.place_end_date').hide(350); }
  })

  // Enable bootstrap tooltips
  jQuery('[data-toggle="tooltip"]').tooltip();

  // category suggestions
  jQuery('.category-input').each(function() {
    var input = this;
    var categoryList = new Awesomplete(input, {
      minChars: 1,
      filter: function(text, input) {
        return Awesomplete.FILTER_CONTAINS(text, input.match(/[^,]*$/)[0]);
      },
      replace: function(text) {
        var before = this.input.value.match(/^.+,\s*|/)[0];
        this.input.value = before + text + ", ";
      }
    });

    jQuery(input).click(function() {
      categoryList.minChars = 0;
      categoryList.evaluate();
      categoryList.open();
    });
  });

	jQuery('#place_start_date').daterangepicker({
		"timePicker": true,
		"timePicker24Hour": true,
		"timePickerIncrement": 15,
		"locale": {
			format: 'DD.MM.YYYY h:mm A'
		},
		"ranges": {
			'Today': [moment().startOf('day'), moment().endOf('day')],
			'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
			'Last 7 Days': [moment().subtract(6, 'days'), moment()],
			'Last 30 Days': [moment().subtract(29, 'days'), moment()],
			'This Month': [moment().startOf('month'), moment().endOf('month')],
			'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
		},
	}, function(start, end, label) {
		console.log("New date range selected: ' + start.format('YYYY-MM-DD') + ' to ' + end.format('YYYY-MM-DD') + ' (predefined range: ' + label + ')");
	});

  jQuery('#set_end_date').on('click', function(){
    picker();
  })
});
