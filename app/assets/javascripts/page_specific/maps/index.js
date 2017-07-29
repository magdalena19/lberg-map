// Map index related JS
jQuery(function() {
  // ----- MAP PANEL SIZE ADJUSTMENT
  jQuery(".map-index.panel-heading").on("click", ".map-title", function() {
    var mapToken = jQuery(this).data("map-token");

    window.location.href = "/" + mapToken;
  });

  // Determine maximum panel height
  function maxPanelHeight() {
    var maxHeight = 0;

    jQuery(".map-panel .panel-body").each(function() {
      var currentPanelHeight = jQuery(this).height();

      maxHeight =
        currentPanelHeight > maxHeight ? currentPanelHeight : maxHeight;
    });

    return maxHeight;
  }

  // Set max height throughout all panels
  jQuery(".map-panel .panel-body").height(maxPanelHeight());
});
