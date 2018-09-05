jQuery(function() {
  window.initWysiwyg = function(element) {
    jQuery('.wysihtml5').each(function(i, e) {
      jQuery(e).wysihtml5({
        toolbar: {
          'font-styles': false,
          'emphasis': true,
          'lists': true,
          'html': true,
          'link': false,
          'image': false,
          'color': false
        }
      });
    });
  };

  initWysiwyg();
})
