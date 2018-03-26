jQuery(function() {
  // move rails-generated hodden id fields
  // out of this scope to allow movements
  jQuery('input[type=hidden]').not('.priority-field').insertAfter(jQuery('#tag_maintainance'));

  // save priority order in hidden input fields
  var assignPriorities = function() {
    jQuery('.category-setting-row').each(function(index, row) {
      var $row = jQuery(row);
      var priority = $row.find('.priority-field');
      priority.val('');
      $row.find('.form-control').each(function() {
        if (jQuery(this).val().length > 0) {
          priority.val(index);
        };
      });
    });
  };
  assignPriorities();

  jQuery('.form-control').on('change', function() {
    assignPriorities();
  });
  jQuery('.form-control').on('keyup', function() {
    assignPriorities();
  });

  jQuery('#tag_maintainance').each(function() {
    jQuery('.icon-selection').on('click', function() {
      var that = this;
      jQuery('#icon-selection-modal').modal('show');
      jQuery('.font-awesome-icon').unbind().click(function() {
        jQuery(that).val(jQuery(this).data('fa-class'));
        assignPriorities();
        jQuery('#icon-selection-modal').modal('hide');
      });
    });
  });

  jQuery('.delete-category').click(function() {
    var $parent = jQuery(this).parents(".category-setting-row");
    $parent.find('.form-control').each(function(index, field) {
      $parent.find('.destroy-checkbox').prop('checked', true);
      $parent.hide();
    });
    assignPriorities();
  });

  jQuery('.category-up').click(function() {
    var $parent = jQuery(this).parents(".category-setting-row");
    $parent.insertBefore($parent.prev());
    assignPriorities();
  });

  jQuery(".category-down").click(function() {
    var $parent = jQuery(this).parents(".category-setting-row");
    $parent.insertAfter($parent.next());
    assignPriorities();
  });

});