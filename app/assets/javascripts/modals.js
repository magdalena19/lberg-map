// MAP MODALS
jQuery(function(){
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

  // MAP EMBEDDING
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

  // MAP SHARING
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
        alert('Something went wrong!');
      }
    })
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
})
