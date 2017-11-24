jQuery(function(){
  // ------ MAP MODALS
  jQuery('.map-modal-button').on('click', function(){
    target = jQuery(this).data('target');
    id = jQuery(this).data('map-id');

    jQuery('#' + target + '_' + id).modal('show');
  });

  // Toggle map elements if modal action is triggered
  jQuery('.modal').on('hidden.bs.modal', function() {
    showMapElements();
  });

  jQuery('.modal').on('show.bs.modal', function() {
    hideMapElements();
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
