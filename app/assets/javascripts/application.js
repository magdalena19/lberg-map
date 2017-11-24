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
//= require wysiwyg
//= require tagging
//= require place_form
//= require navbar
//= require footer

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

  // Enable bootstrap tooltips
  jQuery('[data-toggle="tooltip"]').tooltip();

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
});
