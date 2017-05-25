//= require phantomjs_polyfill-rails/bind-polyfill
//= require jquery
//= require jquery.scrollTo
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-sprockets
//= require bootstrap-wysihtml5
//= require awesomplete
//= require moment
//= require dataTables/jquery.dataTables
//= require dataTables.fixedHeader.min
//= require dataTables_responsive
//= require datetime-moment
//= require daterangepicker

jQuery(function() {
  if (window.history.length === 1) {
    jQuery('.back-button').hide();
  }

  jQuery('#flash-messages').delay(4000).fadeOut(800);
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

  // Deactivate "send copy to sender" option if no email address is present
  jQuery('#message_sender_email').on('input', function(val){
    var current_value = $(this).val();
    if (current_value !== '') {
      jQuery('.email_reply').show(350);
    } else {
      jQuery('.email_reply').hide(350);
    }
  });

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

  jQuery('#is_place').on('click', function(){
    jQuery('#place_start_date').prop('disabled', true);
    jQuery('#set_end_date').prop('disabled', true);
  });

  jQuery('#is_event').on('click', function(){
    jQuery('#place_start_date').prop('disabled', false);
    jQuery('#set_end_date').prop('disabled', false);
    picker(
        jQuery('#place_start_date'),
        jQuery('#set_end_date').is(':checked')
        );
  });

  jQuery('#set_end_date').on('click', function(){
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

    function proposeTags(inputField) {
      // Determine diff of category and input words array
      var origList = jQuery(inputField).data('list').replace(/ /g, '').split(',');
      var inputWords = jQuery(inputField)[0].value.replace(/ /g, '').split(',');
      var diff = origList.filter(function(n) {
        return inputWords.indexOf(n) === -1;
      });

      categoryList._list = diff;
      categoryList.minChars = 0;
      categoryList.evaluate();

      if (diff.length !== 0) {
        categoryList.open();
      }
    }

    jQuery(input).click(function() {
      proposeTags(this);
    });

    jQuery(input).on('input', function() {
      proposeTags(this);
    });
  });

  // landing page
  jQuery('.login-form').hide();
  jQuery('.create-with-account').click(function() {
    jQuery(this).prop('disabled', true);
    jQuery('.login-form').show();
  });

  // MAP VIEWS (form, index, ...)
  var toggle_if_checked = function(checkbox_id, div_to_toggle) {
    jQuery(checkbox_id).on('click', function(){
      var checked = $(this).is(':checked');
      if (checked) {
        jQuery(div_to_toggle).show(350);
      } else {
        jQuery(div_to_toggle).hide(350);
      }
    });
  };

  // Form

  // Password
  jQuery('.password-checkbox').on('click', 'input', function() {
    var checkbox = jQuery(this)[0];
    var passwordField = jQuery('#map_password');
    var passwordConfirmationField = jQuery('#map_password_confirmation');

    if (checkbox.checked) {
      passwordField.
        attr('disabled', false).
        attr('placeholder', '•••••')
      passwordConfirmationField.
        attr('disabled', false).
        attr('placeholder', '•••••')
    } else {
      passwordField.
        attr('disabled', true).
        val('').
        attr('placeholder', '')
      passwordConfirmationField.
        attr('disabled', true).
        val('').
        attr('placeholder', '')
    }
  });

  toggle_if_checked('#map_auto_translate', '#map_translation_engine');

  jQuery('#map_is_public').on('click', function(){
    var checked = jQuery(this).is(':checked');
    if (checked) {
      jQuery('.map-public-settings').show(350);
    } else {
      jQuery('.map-public-settings').hide(350);
    }
  })

  // generate public token
  function camelize(string) {
    return string.toLowerCase().split(' ').join('_');
  }

  jQuery('#map_title').on('input', function(){
    title = jQuery(this).val();
    var public_token_input = jQuery('#map_public_token');
    public_token_input.val(camelize(title)).trigger('change');
  })

  // Index
  jQuery('.map_description_button').on('click', function(){
    secret_token = jQuery(this).data('map-token');
    modal = jQuery('#map_description_' + secret_token);
    modal.modal('show');
  });

  // Invitation
  jQuery('#share_admin_link').on('click', function(){
    jQuery('#map_admins_field').toggle();
  });

  var toggle_submit_invitations_button = function() {
    var map_guests_invites = jQuery('#map_guests').val() !== '';
    var map_admin_invites = jQuery('#map_admins').val() !== '';

    if (map_guests_invites || map_admin_invites) {
      jQuery('#submit_invitations').prop('disabled', false);
    } else {
      jQuery('#submit_invitations').prop('disabled', true);
    }
  };

  jQuery('#map_admins').on('input', function(){
    toggle_submit_invitations_button();
  });

  jQuery('#map_guests').on('input', function(){
    toggle_submit_invitations_button();
  });

  // FOOTER ACTIONS
  jQuery('.app_imprint_toggle').on('click', function(){
    jQuery('#app_imprint').modal('show');
  });

  jQuery('.app_privacy_policy_toggle').on('click', function(){
    jQuery('#app_privacy_policy').modal('show');
  });

  // EXPLANATION MODALS
  var explanationIcon = jQuery('.explanation');
  explanationIcon.addClass('glyphicon glyphicon-question-sign');
  explanationIcon.click(function() {
    var text = jQuery(this).data('explanation');
    jQuery('#explanation-modal').find('.modal-body').text(text);
    jQuery('#explanation-modal').modal('show');
  });

  // Close modals on Escape keypress
  window.addEventListener("keydown", function (event) {
    if (event.defaultPrevented) {
      return; // Should do nothing if the key event was already consumed.
    }

    switch (event.key) {
      case "Escape":
        jQuery('.modal').modal('hide');
      break;
      default:
      return; // Quit when this doesn't handle the key event.
    }

    // Consume the event to avoid it being handled twice
    event.preventDefault();
  }, true);
});
