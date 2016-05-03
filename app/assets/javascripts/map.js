var all = function() {
  jQuery('#map').each(function() {

    jQuery(window).resize(function(){
      var innerHeight = jQuery(window).height() - jQuery('.navbar').outerHeight() - 50;
      jQuery('#map').height(innerHeight);
    }).resize();

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
        $(this).html('Cancel')
        jQuery('#map').css('cursor','crosshair');
        map.on('click', function(e) {
          var params = 'longitude=' + e.latlng.lng + '&' + 'latitude=' +  e.latlng.lat;
          window.location.href = 'places/new?' + params;
        });
      } else {
        $(this).html('Point to a new place');
        jQuery('#map').css('cursor','');
        map.off('click');
      };
    });
  });
};

jQuery(function() { all(); });
jQuery(document).on('page:load', all);