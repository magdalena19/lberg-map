jQuery(function() {
  window.initCategoryInput = function(origList) {
    var categoriesField = $('.place-modal input#place_categories_string');
    var selectedCategories = categoriesField.data('categories');

    // Place form tagging
    function isSelected(category) {
      return selectedCategories.indexOf(category) != -1;
    }

    function createBadge(category) {
      var categoryElement = document.createElement("span");
      var selectionStatus = isSelected(category) ? 'selected' : 'deselected'

      categoryElement.classList.add('category', 'badge', selectionStatus);
      categoryElement.innerHTML = category;
      categoryElement.dataset.category = category;
      return categoryElement;
    }

    function toggleSelection(category) {
      $(category).toggleClass('selected');
      $(category).toggleClass('deselected');
      updateCategoriesFormField(category.dataset.category);
    }

    function updateCategoriesFormField(category) {
      if (isSelected(category)) {
        selectedCategories.splice($.inArray(category, selectedCategories), 1);
      } else {
        selectedCategories.push(category);
      }

      var newCategoriesString = $.unique(selectedCategories).join(',');
      categoriesField.val(newCategoriesString)
    }

    $('.categories').each(function() {
      var that = $(this);
      var categories = origList.split(',');
      $.each(categories, function(i, category) {
        that.append(createBadge(category));
      })
    });

    $('.category').on('click', function() {
      toggleSelection(this);
    })


    // Map search field tagging
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
