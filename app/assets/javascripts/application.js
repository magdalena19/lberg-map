// VENDOR CODE
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

// CUSTOM CODE
//= require ./modals

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

  // LANDING PAGE
  jQuery('.login-form').hide();
  jQuery('.create-with-account').click(function() {
    jQuery(this).prop('disabled', true);
    jQuery('.login-form').show();
  });

  // FOOTER ACTIONS
  jQuery('.app_imprint_toggle').on('click', function(){
    jQuery('#app_imprint').modal('show');
  });

  jQuery('.app_privacy_policy_toggle').on('click', function(){
    jQuery('#app_privacy_policy').modal('show');
  });
});
