var all = function() {

  map = L.map('map');
  map.options.minZoom = 2;
  url = 'http://otile1.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png';
    baselayer = L.tileLayer(url, {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    });
    map.addLayer(baselayer);
    map.setView([52.513, 13.474], 12);

    jQuery.each(window.places, function( index, props ) {
      var openPopup = function(e) {
        jQuery('.popup').remove();
        jQuery('#map').append("<div class='popup'>" + props[2] + "</div>");
      };
      L.circleMarker(props, {radius: 8, fillOpacity: 0.5})
        .on('click', openPopup)
        .addTo(map);
    });
}

jQuery( function() { all(); });
jQuery(document).on('page:load', all);