var all = function() {

  map = L.map('map');
  map.options.minZoom = 2;

  url = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    baselayer = L.tileLayer(url, {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    });
    map.addLayer(baselayer);
    map.setView([10, -10], 2);

    jQuery.each(window.places, function( index, value ) {
      L.circle(value, 500, {
              color: 'red',
              fillColor: '#f03',
              fillOpacity: 0.5
          }).addTo(map);
    });


    console.log(window.places);


}


jQuery( function() { all(); });

jQuery(document).on('page:load', all);