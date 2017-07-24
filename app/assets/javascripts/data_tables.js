jQuery(function() {
  $.fn.dataTable.moment('YYYY-MM-DD HH:mm:ss');

  function renderDate(date) {
    if (date === '') {
      return '';
    } else {
      return moment(date).utc().format('DD.MM.YYYY HH:mm');
    }
  }

  jQuery('#places').DataTable({
    fixedHeader: {
      header: true,
      headerOffset: $('.modal-header').outerHeight()
    },
    responsive: true,
    'paging': false,
    'bInfo': false,
    'order': [[0, 'asc']],
    'language': {search: ''},
    'aoColumnDefs': [{
      'aTargets': [2, 3],
      'mDataProp': function(source, type, val) {
        if (type === 'set') {
          source[0] = val;
          source.date_rendered = renderDate(val);
          return;
        } else if (type === 'display' || type === 'filter') {
          return source.date_rendered;
        }
        return source[0];
      }
    }]
  });

  jQuery('#users_table').DataTable({
    responsive: true,
    paging: true,
    lengthChange: false,
    info: false,
    pageLength: 25,
    'aoColumnDefs': [
    {'bSortable': false, 'aTargets': [4, 5]}
    ]
  });

  jQuery('#places_to_review').DataTable({
    responsive: true,
    'searching': false,
    'paging': false,
    'bInfo': false,
    'order': [[1, 'asc']],
    'aoColumnDefs': [
    {'bSortable': false, 'aTargets': [0]}
    ]
  });

  jQuery('#translations').DataTable({
    responsive: true,
    'searching': false,
    'paging': false,
    'bInfo': false,
    'order': [[1, 'asc']],
    'aoColumnDefs': [
    {'bSortable': false, 'aTargets': [0]}
    ]
  });

  var collapseAllDetails = function() {
    jQuery('#places').find('.parent').find('td').trigger('click');
  };

  // Does not work...
  $('#places > tbody').on('click', 'td.details-control', function() {
    var table = jQuery('#places').dataTable();
    var tr = $(this).closest('tr');
    var row = table.api().row(tr); // Maybe cause of that?
    var hiddenColumns = row.find('td:hidden').addClass('hidden');
  });
});
