// Everything related to repositioning elements within iframe views

jQuery(function() {

  // Assume iframe view if no navbar displayed
  if (jQuery('.navbar')[0] === undefined) {
    var footer = jQuery('.footer');

    jQuery('.filter-field').css('top', 0); // Adjust filter field height
    footer.
      css('background-color', 'rgba(0, 0, 0, 0)'). // Make footer transparent
      find('.container').
      css('color', 'black'). // Black font
      css('text-shadow', '1px 1px 8px'). // Shadow
      find('a').css('color', 'black'); // Black link font
  }
});
