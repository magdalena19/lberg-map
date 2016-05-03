var all = function() {
  jQuery('#map').each(function() {
    map = L.map('map');
    map.options.minZoom = 2;
    url = '//tile-{s}.openstreetmap.fr/hot/{z}/{x}/{y}.png';
    baselayer = L.tileLayer(url, {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    });
    map.addLayer(baselayer);
    map.setView([52.513, 13.474], 12);

    jQuery.each(window.placesJson, function( index, feature ) {
      var openPopup = function(e) {
        jQuery('.popup').remove();
        jQuery('#map').append("<div class='popup'>" +
                                  feature.properties.name +
                                  ' (' + feature.properties.categories + ')' +
                              "</div>");
      };
      L.circleMarker(feature.geometry.coordinates, {radius: 8, fillOpacity: 0.5})
        .on('click', openPopup)
        .addTo(map);
    });

    // REVERSE GEOCODING
    $('.geocode-button').click(function(){
      $('#map').toggleClass('active');
      $(this).toggleClass('active');
      if ($(this).hasClass('active')) {
        jQuery('#map').css('cursor','crosshair');
        map.on('click', function(e) {
          var params = 'longitude=' + e.latlng.lng + '&' + 'latitude=' +  e.latlng.lat;
          window.location.href = 'places/new?' + params;
        });
      } else {
        jQuery('#map').css('cursor','');
        map.off('click');
      };
    });
  });
};

jQuery(function() { all(); });
jQuery(document).on('page:load', all);