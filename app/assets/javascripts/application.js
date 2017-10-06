//= require phantomjs_polyfill-rails/bind-polyfill
//= require jquery
//= require jquery.scrollTo
//= require jquery_ujs
//= require spectrum
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

//= require ./page_specific/maps/show/_map_overlays
//= require place_form

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

  // landing page
  jQuery('.login-form').hide();
  jQuery('.create-with-account').click(function() {
    jQuery(this).prop('disabled', true);
    jQuery('.login-form').show();
  });

  // ------ MAP MODALS
  jQuery('.map-modal-button').on('click', function(){
    target = jQuery(this).data('target');
    id = jQuery(this).data('map-id');

    jQuery('#' + target + '_' + id).modal('show');
  });

  // Toggle map elements if modal action is triggered
  jQuery('.map-container .modal').on('hidden.bs.modal', function() {
    showMapElements();
    hidePlacesListPanel();
  });

  jQuery('.map-container .modal').on('show.bs.modal', function() {
    hideMapElements();
  });

  // ----- MAP EMBEDDING
  function updateIframeString(element) {
    var iframeString = jQuery('#iframe_src').val()
    var attribute = element.data('target');
    var newValue = element.val();
    var oldValMatcher= new RegExp(attribute + '="\\d*"');
    var newValueString = attribute + '="' + newValue + '"';

    jQuery('.modal-content #iframe_src').val(iframeString.replace(oldValMatcher, newValueString)).trigger('change');
  }

  function updateValues(element) {
    var attribute = element.data('target');
    var newValue = element.val();

    jQuery('.embed-map .modal-content .text-field').each( function() {
      if (jQuery(this).data('target') === attribute ) {
        jQuery(this).val(newValue).change();
      }
    });
  }

  jQuery('.embed-form-element').on('change', function() {
    var element = jQuery(this);

    updateIframeString(element);
    updateValues(element);
  });


  // copy to clipboard
  jQuery('.modal-content .clipboard-btn').on('click', function() {
    var inputVal = jQuery(this).parent().prev().val();

    try {
      // document.execCommand(...) not working within BS modals
      // Workaround: Create DOM element, copy content of input field, copy to clipboard, remove DOM element
      var temp = $("<input>");

      $("body").append(temp);
      temp.val(inputVal).select();
      document.execCommand('copy'); // copy text
      temp.remove();
    }
    catch (err) {
      alert('please press Ctrl/Cmd+C to copy');
    }
  });

  // ------ MAP SHARING
  // grecaptcha.render('share-map-captcha', {'sitekey' : '6LeGjiUUAAAAABqmRwzkgx4svjseCaFSgeoKcABM'});

  jQuery('.share-admin-link').on('click', function(){
    jQuery('.modal-content #map_admins').toggle();
  });

  jQuery('.modal-content .invite-form-field').on('input', function(){
    var parentModal = jQuery(this).closest('.share-map-modal');
    var bla1 = parentModal.find('#map_guests').val();
    var bla2 = parentModal.find('#map_admins').val();
    var hasMapGuestInvitees = bla1 === '' || bla1 === undefined ? false : true;
    var hasMapAdminInvitees = bla2 === '' || bla2 === undefined ? false : true;

    if ( hasMapGuestInvitees || hasMapAdminInvitees ) {
      jQuery('.modal-content #submit_invitations').prop('disabled', false);
      jQuery('.modal-content .captcha').fadeIn(350);
    } else {
      jQuery('.modal-content #submit_invitations').prop('disabled', true);
      jQuery('.modal-content .captcha').fadeOut(350);
    }
  });

  jQuery('.modal-content #submit_invitations').on('click', function() {
    var mapId = jQuery(this).data('map-id');
    var parentModal = jQuery(this).closest('.share-map-modal');
    var mapGuestInvitees = parentModal.find('#map_guests').val();
    var mapAdminInvitees = parentModal.find('#map_admins').val();

    jQuery.ajax({
      url: '/share_map/' + mapId,
      data: { map_admins: mapAdminInvitees, map_guests: mapGuestInvitees, id: mapId },
      type: 'POST',
      context: this,
      success: function() {
        jQuery(this).closest('.share-map-modal').modal('hide');
      },
      error: function() {
        alert('Something went wrong!')
      }
    })
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

  // color logo
  var logo = jQuery('.navbar-logo');
  var words = logo.text().split(' ');
  logo.empty();
  jQuery.each(words, function(i, word) {
    var color = i % 2 == 0 ? 'green' : 'lilac'
    logo.append("<div class='navbar-logo-" + color + "'>" + word + "</div>");
  });
});
