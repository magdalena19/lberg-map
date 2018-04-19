jQuery(function() {
  // NAVBAR
  var logo = jQuery('.navbar-logo');
  var words = logo.text().split(' ');
  logo.empty();
  jQuery.each(words, function(i, word) {
    var color = i % 2 == 0 ? 'green' : 'lilac'
    logo.append("<div class='navbar-logo-" + color + "'>" + word + "</div>");
  });
})
