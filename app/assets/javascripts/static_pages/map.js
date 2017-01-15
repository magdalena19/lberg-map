//= require leaflet
//= require leaflet.markercluster
//= require static_pages/map_overlays

jQuery(function() {
  jQuery('#map').each(function() {
    // move flash message in foreground when map is displayed
    jQuery('#flash-messages').css('position', 'absolute').css('z-index', '999999');

    map = L.map('map', {
      zoomControl: false,
      minZoom: 5,
      maxZoom: 18
    });
    jQuery('.zoom-in').click(function() {map.zoomIn()});
    jQuery('.zoom-out').click(function() {map.zoomOut()});

    var addMap = function(url) {
      baselayer = L.tileLayer(url, {attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors'});
      map.addLayer(baselayer);
      map.setView([52.513, 13.4], 12);
    };

    $.ajax({
      url: 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/1/1/1.jpg',
      success: function(result) {
        addMap('https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.jpg');
      },
      error: function(result) {
        addMap('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png');
      }
    });

    var autotranslatedPrefix = "<p><i>" + window.autotranslated_label + ": </i></p>";
    var waitingForReviewSuffix = "<span style='color: #ff6666;'> | " + window.waiting_for_review_label + "</span>";

    var placeSlidePanel = jQuery('.place-slidepanel')
    var onEachFeature = function(feature, layer) {
      var prop = feature.properties;
      var waitingForReviewSuffix = "<span style='color: #ff6666;'> | " + window.waiting_for_review_label + "</span>";
      var homepageLink = prop.homepage.link(prop.homepage_full_domain);

      if (prop.reviewed === false) {
        layer.setIcon(session_icon);
      }

      layer.on('click', function(e) {
        placeSlidePanel.find('.edit-place').attr('place_id', prop.id);
        placeSlidePanel.find('.name').html(prop.name);

        if (prop.reviewed) {
          placeSlidePanel.find('.name').html(prop.name);
        } else {
          placeSlidePanel.find('.name').html(prop.name + waitingForReviewSuffix);
          jQuery('.edit-place').hide();
        }

        if (prop.translation_auto_translated) {
          placeSlidePanel.find('.place-description').html("<a href='places/" + prop.id + "/edit' class='btn btn-xs btn-danger'>" + window.autotranslated_label + "</a>" + '<br>' + prop.description);
        } else {
          placeSlidePanel.find('.place-description').html(prop.description);
        }

        placeSlidePanel.find('.place-address').html(prop.address);
        placeSlidePanel.find('.place-email').html(prop.email);
        placeSlidePanel.find('.place-homepage').html(homepageLink);
        placeSlidePanel.find('.place-phone').html(prop.phone);
        placeSlidePanel.trigger('open');
      });
    };

    jQuery('.edit-place').click(function() {
      var placeId = jQuery(this).attr('place_id');
      window.location.href = 'places/' + placeId + '/edit';
    });

    var icon =  L.icon({
      iconUrl: marker,
      iconSize: [40, 40]
    });

    var session_icon =  L.icon({
      iconUrl: sessionMarker,
      iconSize: [40, 40]
    });

    var updatePlaces = function(json) {
      if (typeof cluster !== 'undefined') {
        map.removeLayer(cluster);
      }
      cluster = L.markerClusterGroup({
        polygonOptions: {
          fillColor: 'rgb(109, 73, 129)',
          weight: 0,
          fillOpacity: 0.3
        }
      });
      var marker = L.geoJson(json, {
        pointToLayer: function (feature, latlng) {
          return L.marker(latlng, {icon: icon});
        },
        onEachFeature: onEachFeature
      });
      cluster.addLayer(marker);
      map.addLayer(cluster);
    };

    // CATEGORY AND PLACE BUTTONS
    var filter = function(json, categoryId) {
      var filteredJson = [];
      jQuery(json).each(function (id, feature) {
        if (jQuery.inArray(categoryId, feature.properties.categories) !== -1) {
          filteredJson.push(feature);
        };
      });
      return filteredJson;
    };

    jQuery('.category-button').click(function() {
      closeAllPanels();
      jQuery('.category-panel').trigger('close');
      jQuery('.category-button').removeClass('active');
      jQuery(this).addClass('active');
      var categoryId = jQuery(this).attr('id');
      var category = jQuery(this).text();
      if (jQuery(this).is('#all')) {
        jQuery('.show-categories-text').html(window.choose_category);
        updatePlaces(window.places, categoryId);
      } else {
        jQuery('.show-categories-text').html(category);
        updatePlaces(filter(window.places, categoryId));
      };
    });
    jQuery('.category-button#all').click();

    jQuery('.loading').show();
    jQuery.ajax({
      url: '/',
      dataType: 'json',
      data: {
        locale: window.locale
      },
      success: function(result) {
        window.places = result;
        updatePlaces(window.places);
        jQuery('.loading').hide();
      }
    });

    // ADD PLACE
    jQuery('.add-place-buttons').click(function(){
      jQuery('.add-place-slidepanel').trigger('close');
    });

    jQuery('.type-in-address').click(function(){
      window.location.href = 'places/new';
    });

    var locationMarker;

    function confirmPlaceInsert(lat, lon) {
      map.setView([lat, lon], 18);
      if (locationMarker) {
        map.removeLayer(locationMarker);
      }
      locationMarker = L.circleMarker([lat, lon]).addTo(map);
      jQuery('.confirmation-button-container').fadeIn();
      jQuery('#confirmation-button-yes').click(function() {
        jQuery('.confirmation-button-container').fadeOut();
        var params = 'longitude=' + lon + '&' + 'latitude=' +  lat;
        window.location.href = 'places/new?' + params;
      });
      jQuery('#confirmation-button-no').click(function() {
        jQuery('.confirmation-button-container').fadeOut();
        window.location.href = 'places/new';
      });
    }

    // Google geolocation API not working properly, so freeze this feature

    // jQuery('.add-place-via-location').click(function(){
    //   function confirmation(position) {
    //     confirmPlaceInsert(position.coords.latitude, position.coords.longitude);
    //   };
    //
    //   if (navigator.geolocation) {
    //     navigator.geolocation.getCurrentPosition(confirmation);
    //   } else {
    //     console.log('Geolocation is not supported by this browser.');
    //   };
    // });

    jQuery('.add_place_via_click').click(function(){
      jQuery('.leaflet-overlay-pane').css('cursor','crosshair');
      map.on('click', function(point) {
        confirmPlaceInsert(point.latlng.lat, point.latlng.lng);
      });
    });


    // FRONTEND STUFF
    var toggleTriangle = function(e) {
      jQuery(e.target)
      .prev('.panel-heading')
      .find('.triangle')
      .toggleClass('glyphicon-triangle-bottom glyphicon-triangle-top');
    }
    jQuery('#accordion')
    .on('hidden.bs.collapse', toggleTriangle)
    .on('shown.bs.collapse', toggleTriangle);

    // ZOOM TO PLACE
    jQuery('.zoom-to-place').click(function() {
      jQuery('.category-button#all').click();
      var lat = jQuery(this).attr('latitude');
      var lon = jQuery(this).attr('longitude');
      map.setView([lat, lon], 16);
    });

    // external request
    setTimeout(function() {
      if (window.latitude > 0 && window.longitude > 0) {
        coordinates = [window.latitude, window.longitude];
        map.setView(coordinates, 16);
      }
    }, 1);

    // RESPONSIVE HEIGHT
    jQuery(window).resize(function(){
      var navbarHeight = jQuery('.navbar').height();
      jQuery('.map-container').height(jQuery(window).height()).css('margin-top', - (navbarHeight + 15));
      jQuery('.confirmation-button-container').css('top', navbarHeight + 3);
      balanceSidebar();
      resizePanels();
    }).resize();
  });
});
