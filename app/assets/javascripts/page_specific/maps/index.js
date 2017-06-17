// Map index related JS
jQuery(function() {

  // ----- MAP PANEL SIZE ADJUSTMENT
  jQuery('.map-index.panel-heading').on('click', '.map-title', function() {
    var mapToken = jQuery(this).data('map-token');

    window.location.href = '/' + mapToken;
  });

  // Determine maximum panel height
  function maxPanelHeight() {
    var maxHeight = 0;

    jQuery('.map-panel .panel-body').each( function() {
      var currentPanelHeight = jQuery(this).height();

      maxHeight = currentPanelHeight > maxHeight ? currentPanelHeight : maxHeight;
    });

    return(maxHeight);
  }

  // Set max height throughout all panels
  var height = maxPanelHeight();
  jQuery('.map-panel .panel-body').height(height);


  // ----- MAP EMBEDDING

  jQuery('.embed-map-button').on('click', function(){
    id = jQuery(this).data('map-id');
    jQuery('#embed_map_' + id).modal('show');
  });

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

    jQuery('.embed_map .modal-content .text-field').each( function() {
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
      // input.select(); // Select input field text
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


});
