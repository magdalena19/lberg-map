jQuery(function() {
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
        jQuery('#place-modal').modal('show')
        jQuery('.modal-title').html(feature.properties.name);
        jQuery('.modal-body').html(feature.properties.address + '<br><br>' + feature.properties.description);
      };
      var marker = L.circleMarker(feature.geometry.coordinates, {radius: 8, fillOpacity: 0.5});
      marker.on('click', openPopup);
      marker.addTo(map);
    });

    // REVERSE GEOCODING
    $('.geocode-button').click(function(){
      $('#map').toggleClass('active');
      $(this).toggleClass('active');
      if ($(this).hasClass('active')) {
        $(this).html("<div class='glyphicon glyphicon-remove-circle'></div>")
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
});
