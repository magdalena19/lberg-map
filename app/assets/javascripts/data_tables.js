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

  jQuery('.dataTable').find('.sorting_1').click(function() {
    var row = jQuery(this);
      if (row.parent().hasClass('parent')) {
        row.find('.triangle').addClass('glyphicon-triangle-bottom').removeClass('glyphicon-triangle-top');
      } else {
        row.find('.triangle').addClass('glyphicon-triangle-top').removeClass('glyphicon-triangle-bottom');
      };
  });
});
