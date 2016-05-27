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

    var onEachFeature = function(feature, layer) {
      console.log(feature.id);
      layer._leaflet_id = feature.id; // for 'getLayer' function
      layer.on('click', function(e) {
        jQuery('.popup').remove();
        jQuery('.modal-title').html(feature.properties.name);
        jQuery('.modal-body').html(feature.properties.address + '<br><br>' + feature.properties.description);
        jQuery('#place-modal').modal('show');
      });
    };

    var addPlaces = function(json) {
      marker = L.geoJson(json, {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng);
        },
        onEachFeature: onEachFeature
      }).addTo(map);
    };
    addPlaces(window.placesJson);

    // CATEGORY AND PLACE BUTTONS
    jQuery('.place-button')
      .hover(function() {
        clickedPlace = marker.getLayer(this.id);
        map.setView(clickedPlace.getLatLng(), 14, {animate: true});
      })
      .click(function() {
        properties = marker.getLayer(this.id).feature.properties;
        jQuery('.modal-title').html(properties.name);
        jQuery('.modal-body').html(properties.address + '<br><br>' + properties.description);
        jQuery('#place-modal').modal('show');
      });


    jQuery('.category-button#all').addClass('active');

    jQuery('.category-button').click( function() {
      jQuery('.category-button').removeClass('active');
      jQuery(this).addClass('active');
      var categoryId = jQuery(this).attr('id');
      $.ajax({
        url: "/",
        data: {
                category: categoryId,
                locale: window.locale,
              },
        success: function(result){
          map.removeLayer(marker);
          addPlaces(result);
        }
      });
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
