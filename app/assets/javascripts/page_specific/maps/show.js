//= require map_base
//= require ./_map_overlays

jQuery(function() {
  jQuery('#map').each(function() {
    // move flash message in foreground when map is displayed
    jQuery('#flash-messages').css('position', 'absolute').css('z-index', '999999');

    addEsriMap([52.513, 13.4], 12);

    // still to be used!
    var autotranslatedPrefix = "<p><i>" + window.autotranslated_label + ": </i></p>";
    var waitingForReviewSuffix = "<span style='color: #ff6666;'> | " + window.waiting_for_review_label + "</span>";

    var onEachFeature = function(feature, layer) {
      addToPlacesList(feature);
      var prop = feature.properties;
      if (prop.reviewed === false) {
        layer.setIcon(session_icon);
      }
      layer.on('click', function(e) {
        jQuery('.places-list-panel').fadeIn();
        var accordionItemHeading = jQuery('#heading' + feature.id);
        var headingLink = accordionItemHeading.find('a');
        if (headingLink.hasClass('collapsed')) {
          headingLink.click();
          var list = jQuery('.places-list-accordion-container');
          list.scrollTo(accordionItemHeading.parent(), {offset: -5});
        }
      });
    };

    // do not use the simpler .click function due to dynamic creation
    jQuery('body').on('click', '.edit-place', function() {
      var placeId = jQuery(this).attr('place_id');
      window.location.href = '/' + window.map_token + '/places/' + placeId + '/edit';
    });

    jQuery('body').on('click', 'a', function() {
      var lat = jQuery(this).attr('lat');
      var lon = jQuery(this).attr('lon');
      map.setView([lat, lon], 14);
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
      jQuery('.places-list-accordion').empty();
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

    // PLACE BUTTONS
    var wordPresent = function(word, feature) {
      var match = false;
      jQuery.each(feature.properties, function(attr, key) {
        var string = feature.properties[attr].toString();
        if ( string.toLowerCase().indexOf(word.trim().toLowerCase()) >= 0 ) {
          match = true;
          return false; // return false to quit loop
        }
      });
      return match;
    };

    var textFilter = function(json) {
      var text = jQuery('#search-input').val();
      if (!text) { return json; }

      var filteredJson = [];
      var words = text.replace(';', ',').split(',');
      jQuery(json).each(function (id, feature) {
        var matches = jQuery.map(words, function(word) {
          return wordPresent(word, feature);
        });
        if ( !(matches.indexOf(false) > -1) ) {
          filteredJson.push(feature);
        }
      });
      return filteredJson;
    };

    // ADD PLACE
    jQuery('.add-place-button').click(function() {
      jQuery('.places-list-panel').fadeIn();
      jQuery('.sidepanel-button-container').hide();
      jQuery('.sidepanel-add-place-container').show();
      resizeSidePanel();
    });

    jQuery('.cancel-place-addition').click(function() {
      jQuery('.sidepanel-add-place-container').hide();
      jQuery('.sidepanel-default-container').show();
      resizeSidePanel();
    });

    jQuery('.hide-places-list-panel').click(function() {
      jQuery('.places-list-panel').fadeOut();
    });

    jQuery('.type-in-address').click(function(){
      window.location.href = '/' + window.map_token + '/places/new';
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
        var params = 'longitude=' + lon + '&latitude=' +  lat;
        window.location.href = '/' + window.map_token + '/places/new?' + params;
      });
      jQuery('#confirmation-button-no').click(function() {
        jQuery('.confirmation-button-container').fadeOut();
        map.removeLayer(locationMarker);
        jQuery('.leaflet-overlay-pane').css('cursor', 'inherit');
        jQuery('.places-list-panel').fadeIn();
      });
    }

    // Google geolocation API not working properly, so freeze this feature
    jQuery('.add-place-via-location').click(function(){
      jQuery('.places-list-panel').fadeOut();
      function confirmation(position) {
        confirmPlaceInsert(position.coords.latitude, position.coords.longitude);
      };
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(confirmation);
      } else {
        console.log('Geolocation is not supported by this browser.');
      };
    });

    jQuery('.add_place_via_click').click(function(){
      jQuery('.places-list-panel').fadeOut();
      jQuery('.leaflet-overlay-pane').css('cursor','crosshair');
      map.on('click', function(point) {
        confirmPlaceInsert(point.latlng.lat, point.latlng.lng);
      });
    });

    // external request
    setTimeout(function() {
      if (window.latitude > 0 && window.longitude > 0) {
        coordinates = [window.latitude, window.longitude];
        map.setView(coordinates, 16);
      }
    }, 1);

    // RESPONSIVE HEIGHT
    var resizeSidePanel = function() {
      var navbarHeight = jQuery('.navbar').height();
      jQuery('.confirmation-button-container').css('top', navbarHeight + 3);
      var placesList = jQuery('.places-list-panel');
      var accordion = jQuery('.places-list-accordion-container');
      var searchField = jQuery('.search-field');
      var buttons = jQuery('.button-container');
      accordion.height(placesList.height() - searchField.outerHeight() - buttons.outerHeight() - 30);
      placesList.show();
    };

    jQuery(window).resize(function(){
      resizeSidePanel();
    }).resize();

    // FILL PLACES LIST
    var addToPlacesList = function(feature) {
      var item = jQuery('.places-list-item.template').clone();
      item.removeClass('template');
      item.find('.panel-heading').attr('id', 'heading' + feature.id);
      item.find('a')
        .attr('href', '#collapse' + feature.id)
        .attr('aria-controls', 'collapse' + feature.id)
        .attr('lon', feature.geometry.coordinates[0])
        .attr('lat', feature.geometry.coordinates[1]);
      item.find('.name').html(feature.properties.name);
      item.find('.panel-collapse')
        .attr('id', 'collapse' + feature.id)
        .attr('aria-labelledby', 'heading' + feature.id);
      item.find('.description').append(feature.properties.description);
      var contact = item.find('.contact-container');
      if(feature.properties.phone !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-earphone'></div>" + feature.properties.phone + "</div>");
      }
      if(feature.properties.email !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-envelope'></div>" + feature.properties.email + "</div>");
      }
      if(feature.properties.homepage !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-home'></div>" + feature.properties.homepage + "</div>");
      }
      if(feature.properties.address !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-record'></div>" + feature.properties.address + "</div>");
      }
      item.find('.category-names').append(feature.properties.category_names);
      item.find('.edit-place').attr('place_id', feature.id);
      jQuery('.places-list-accordion').append(item);
    };

    jQuery('body').on('click', '.show-map', function() {
      jQuery('.places-list-panel').fadeOut();
    });

    // LIVE SEARCH
    jQuery('.category-input')
      .on('awesomplete-selectcomplete', function() {
        updatePlaces(textFilter(window.places));
      })
    .on('input', function(){
      updatePlaces(textFilter(window.places));
    });

    // POI LOADING
    hideMapElements();
    jQuery.ajax({
      url: '/' + window.map_token,
      dataType: 'json',
      data: {
        locale: window.locale
      },
      success: function(result) {
        window.places = result;
        updatePlaces(window.places);
        showMapElements();
        jQuery('.loading').hide();
        jQuery('places-list-panel').fadeIn();
      }
    });
  });
});
