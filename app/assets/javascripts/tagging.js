jQuery(function() {
  window.initCategoryInput = function(origList) {
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

        var inputWords = jQuery(inputField)[0].value.replace(/ /g, '').split(',');
        var diff = origList.split(',').filter(function(n) {
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
  };
});
