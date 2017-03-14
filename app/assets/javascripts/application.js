//= require jquery
//= require jquery_ujs
//= require jquery.scrollTo
//= require bootstrap
//= require bootstrap-sprockets
//= require bootstrap-wysihtml5
//= require awesomplete

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

  // Enable bootstrap tooltips
  jQuery('[data-toggle="tooltip"]').tooltip();

  // input field with multiple tags
  var input = document.getElementById('search-input');
  new Awesomplete(input, {
  	filter: function(text, input) {
  		return Awesomplete.FILTER_CONTAINS(text, input.match(/[^ ]*$/)[0]);
  	},
  	replace: function(text) {
  		var before = this.input.value.match(/^.+ \s*|/)[0];
  		this.input.value = before + text + ' ';
  	}
  });

});
