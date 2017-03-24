//= require dataTables/jquery.dataTables
//= require dataTables_responsive

jQuery(function() {
  jQuery('#places').DataTable({
    responsive: true,
    "paging": false,
    "bInfo": false,
    "order": [[ 1, "asc" ]],
    "aoColumnDefs": [
        { 'bSortable': false, 'aTargets': [0, 4] }
     ]
  });

  jQuery('#places_to_review').DataTable({
    responsive: true,
    "searching": false,
    "paging": false,
    "bInfo": false,
    "order": [[ 1, "asc" ]],
    "aoColumnDefs": [
        { 'bSortable': false, 'aTargets': [0] }
     ]
  });

  jQuery('#translations').DataTable({
    responsive: true,
    "searching": false,
    "paging": false,
    "bInfo": false,
    "order": [[ 1, "asc" ]],
    "aoColumnDefs": [
        { 'bSortable': false, 'aTargets': [0] }
     ]
  });

  jQuery('.dataTable').find('td').click(function() {
    var row = jQuery(this);
      if (row.parent().hasClass('parent')) {
        row.find('.triangle').addClass('glyphicon-triangle-bottom').removeClass('glyphicon-triangle-top');
      } else {
        row.find('.triangle').addClass('glyphicon-triangle-top').removeClass('glyphicon-triangle-bottom');
      }
  });

  var collapseAllDetails = function() {
    jQuery('#places').find('.parent').find('td').trigger('click');
  };

  jQuery('.category-toggle').click(function() {
    jQuery('.category-toggle').removeClass('active');
    jQuery(this).addClass('active');
    var category = jQuery(this).attr('data-category');
    collapseAllDetails();

    jQuery('#places > tbody > tr').each(function() {
      if (category == 'all') {
        jQuery(this).show();
      } else {
        var match = jQuery(this).attr('data-categories').indexOf(category) > -1;
        jQuery(this).toggle(match);
      }
    });
  });

});
