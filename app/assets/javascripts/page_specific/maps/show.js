//= require map_base
//= require ./_map_overlays

jQuery(function() {
  // Marker icons
  var current_position_icon = L.icon({
    iconUrl: marker_current_position
  });

  var place_icon = L.icon({
    iconUrl: placeMarker
  });

  var event_icon = L.icon({
    iconUrl: eventMarker
  });

  var session_event_icon = L.icon({
    iconUrl: sessionEventMarker
  });

  var session_place_icon = L.icon({
    iconUrl: sessionPlaceMarker
  });

  jQuery('#map').each(function() {
    // move flash message in foreground when map is displayed
    jQuery('#flash-messages').css('position', 'absolute').css('z-index', '999999');

    addEsriMap([0, 0], 3);

    // ZOOM BUTTONS
    jQuery('.zoom-in').click(function(){
      map.doubleClickZoom.disable();
      setTimeout(function(){
        map.doubleClickZoom.enable();
      }, 500);
      map.setZoom(map.getZoom() + 1);
    });
    jQuery('.zoom-out').click(function(){
      map.doubleClickZoom.disable();
      setTimeout(function(){
        map.doubleClickZoom.enable();
      }, 500);
      map.setZoom(map.getZoom() - 1);
    });

    // still to be used!
    var autotranslatedPrefix = "<p><i>" + window.autotranslated_label + ": </i></p>";
    var waitingForReviewSuffix = "<span style='color: #ff6666;'> | " + window.waiting_for_review_label + "</span>";

    var onEachFeature = function(feature, layer) {
      addToPlacesList(feature);
      var prop = feature.properties;
      if (prop.reviewed === false) {
        if (prop.is_event === true) {
          layer.setIcon(session_event_icon);
        } else {
          layer.setIcon(session_place_icon);
        }
      } else {
        if (prop.is_event === true) {
          layer.setIcon(event_icon);;
        } else {
          layer.setIcon(place_icon);;
        }
      }

      layer.on('click', function(e) {
        showSidepanel();
        var accordionItemHeading = jQuery('#heading' + feature.id);
        var headingLink = accordionItemHeading.find('a');
        if (headingLink.hasClass('collapsed')) {
          headingLink.click();
          var list = jQuery('.places-list-panel');
          list.scrollTo(accordionItemHeading.parent(), {offset: -5});
        }
      });
    };

    // do not use the simpler .click function due to dynamic creation
    jQuery('body').on('click', '.edit-place', function() {
      var placeId = jQuery(this).attr('place_id');
      window.location.href = '/' + window.map_token + '/places/' + placeId + '/edit';
    });

    jQuery('body').on('click', '.delete-place', function() {
      var placeId = jQuery(this).attr('place_id');
      var confirm_delete = confirm(window.delete_confirmation_text);
      var panel = jQuery('#heading' + placeId).parent();

      if (confirm_delete === true) {
        jQuery.ajax({
          url: '/' + window.map_token + '/places/' + placeId,
          type: 'DELETE',
          success: function(result) {
            panel.fadeOut(350, function() { jQuery(this).remove(); });
            updatePlaces(result);
          }
        });
      }
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
          return L.marker(latlng, {icon: place_icon});
        },
        onEachFeature: onEachFeature
      });

      cluster.addLayer(marker);
      map.addLayer(cluster);
      if (json.length > 0) {
        map.fitBounds(cluster.getBounds());
        jQuery('.zoom-to-bbox').removeClass('inactive');
      } else {
        jQuery('.zoom-to-bbox').addClass('inactive');
      }
    };

    // TEXT FILTER
    var wordPresent = function(word, feature) {
      var match = false;

      jQuery.each(feature.properties, function(attr, key) {
        var value = feature.properties[attr];
        var string = value ? value.toString().toLowerCase() : '';
        if ( string.indexOf(word) >= 0 ) {
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
          word = word.trim().toLowerCase();
          return wordPresent(word, feature);
        });
        if ( !(matches.indexOf(false) > -1) ) {
          filteredJson.push(feature);
        }
      });
      return filteredJson;
    };

    // DATE FILTER
    var forceUTC = function(date) {
      // this is a workaround sinde daterangepicker localizes selection - better would be a direct input as utc timestamp
      return date.clone()
        .utcOffset(0)
        .add(date.utcOffset(), 'minutes');
    };

    var dateFilter = function(json) {
      if (!jQuery('#search-date-input').is(':visible')) { return json; }
      var filteredJson = [];

      // Iterate features and push on filter match
      jQuery(json).each(function (id, feature) {
        var daterange = jQuery('#search-date-input').data('daterangepicker');
        var startDate = forceUTC(daterange.startDate);
        var endDate = forceUTC(daterange.endDate);
        var featureStartDate = moment(feature.start_date);
        var featureEndDate = moment(feature.end_date);
        var showPlaces = jQuery('.show-places-toggle')[0].checked;

        if (
            ( featureStartDate >= startDate && featureStartDate <= endDate ) ||
            ( featureEndDate >= startDate && featureEndDate <= endDate ) ||
            ( !feature.is_event && showPlaces )
           ) {
          filteredJson.push(feature);
        }
      });
      return filteredJson;
    };

    // PLACE TYPE FILTER
    function showFeature(feature) {
      var showEvents = jQuery('.show-events-toggle')[0].checked;
      var showPlaces = jQuery('.show-places-toggle')[0].checked;
      if ( (feature.is_event && showEvents) || (!feature.is_event && showPlaces) ) {
        return true;
      } else {
        return false;
      }
    }

    var placeTypeFilter = function(json) {
      var filteredJson = [];
      jQuery(json).each(function (id, feature) {
        if (showFeature(feature)) {
          filteredJson.push(feature);
        }
      });
      return filteredJson;
    };

    var loadAndFilterPlaces = function() {
      updatePlaces(dateFilter(textFilter(placeTypeFilter(window.places))));
    };

    // INSERT CONFIRMATION ACTION
    var locationMarker;

    function confirmPlaceInsert(lat, lon, geocoding_result) {
      // display marker
      map.setView([lat, lon], 18);
      if (locationMarker) {
        map.removeLayer(locationMarker);
      }
      locationMarker = L.circleMarker([lat, lon]).addTo(map);

      // confirmation button
      jQuery('.confirmation-button-container').fadeIn();
      jQuery('#confirmation-button-yes').click(function() {
        var address = {latitude: lat, longitude: lon};
        if (geocoding_result) {
          jQuery.extend(address, geocoding_result.properties.address);
          hideAddressSearchBar();
        }

        jQuery('.confirmation-button-container').fadeOut();
        url = '/' + window.map_token + '/places/new?';

        // Generate URL
        jQuery.each(address, function(prop) {
          url += prop + '=' + address[prop] + '&';
        });

        // Redirect
        window.location.href = url;
      });

      // cancel button
      jQuery('#confirmation-button-no').click(function() {
        jQuery('.confirmation-button-container').fadeOut();
        map.removeLayer(locationMarker);
        jQuery('.leaflet-overlay-pane').css('cursor', 'inherit');
        showMapElements();
        fit_to_bbox();
      });
    }

    // INSERT PLACE MANUALLY
    jQuery('.add-place-manually').on('click', function() {
      window.location.href = '/' + window.map_token + '/places.new';
    });

    // ADD PLACE VIA ONCLICK
    jQuery('.add-place-via-click').click(function(){
      hideMapElements();
      jQuery('.leaflet-overlay-pane').css('cursor','crosshair');
      map.on('click', function(point) {
        confirmPlaceInsert(point.latlng.lat, point.latlng.lng);
      });
    });


    // ADD PLACE VIA CURRENT GEOLOCATION
    jQuery('.add-place-via-location').click(function(){
      hideMapElements();
      jQuery('.leaflet-overlay-pane').css('cursor','crosshair');
      function confirmation(position) {
        confirmPlaceInsert(position.coords.latitude, position.coords.longitude);
      }

      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(confirmation);
      } else {
        console.log('Geolocation is not supported by this browser.');
      }
    });

    // ADD PLACE VIA ADDRESS SEARCH
    jQuery('.add-place-via-address-search').on('click', function() {
      hideMapElements();

      geocode_field = L.Control.geocoder({
        position: 'bottomright',
        collapsed: false
      }).addTo(map);

      showAddressSearchBar();

      geocode_field.markGeocode = function(geocoding_result) {
        lat = geocoding_result.properties.lat;
        lon = geocoding_result.properties.lon;
        hideAddressSearchBar();
        confirmPlaceInsert(lat, lon, geocoding_result);
      };
    });

    jQuery('.fade-background').on('click', function() {
      hideAddressSearchBar();
      showMapElements();
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
      var navbarHeight = jQuery('.navbar').outerHeight();
      var footerHeight = jQuery('.footer').outerHeight();
      jQuery('.confirmation-button-container').css('top', navbarHeight + 3);
      var panel = jQuery('.places-list-panel');
      var filterField = jQuery('.filter-field');
      var buttons = jQuery('.button-container');
      var toggle = jQuery('.toggle-panel');
      panel.css('top', filterField.outerHeight() + navbarHeight + 3);
      panel.height(jQuery(document).height() - filterField.outerHeight() - navbarHeight - footerHeight - 33);
      if (panel.is(':visible')) {
        jQuery('.toggle-panel').css('left', panel.outerWidth());
      } else {
        jQuery('.toggle-panel').css('left', 0);
      }
    };

    // TOGGLE SIDEPANEL
    jQuery('.toggle-panel').click(function() {
      if (jQuery('.places-list-panel').is(':visible')) {
        hideSidepanel();
      } else {
        showSidepanel();
      }
    });

    jQuery(window).resize(function(){
      resizeSidePanel();
    }).resize();

    // FILL PLACES LIST
    var addToPlacesList = function(feature) {
      var item = jQuery('.places-list-item.template').clone();
      var contact = item.find('.contact-container');
      var event_container = item.find('.event-container');
      var panelType = feature.is_event ? 'event-panel' : 'place-panel'

      item.removeClass('template');
      item.find('.panel-heading').addClass(panelType);
      item.find('.panel-heading').attr('id', 'heading' + feature.id);
      item.find('a')
        .attr('href', '#collapse' + feature.id)
        .attr('aria-controls', 'collapse' + feature.id)
        .attr('lon', feature.geometry.coordinates[0])
        .attr('lat', feature.geometry.coordinates[1]);
      item.find('.name').html(feature.properties.name);
      if (feature.is_event === true) {
        item.find('.place_type').addClass('fa-calendar ' + panelType);
      } else {
        item.find('.place_type').addClass('glyphicon-home ' + panelType);
      }
      item.find('.panel-collapse')
        .attr('id', 'collapse' + feature.id)
        .attr('aria-labelledby', 'heading' + feature.id);
      item.find('.description').append(feature.properties.description);


      // Add place information sub-panels
      if(feature.properties.address !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-record'></div>" + feature.properties.address + "</div>");
      }
      if(feature.properties.phone !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-earphone'></div>" + feature.properties.phone + "</div>");
      }
      if(feature.properties.email !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-envelope'></div>" + feature.properties.email + "</div>");
      }
      if(feature.properties.homepage !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-home'></div>" + feature.properties.homepage + "</div>");
      }
      if(feature.start_date !== null) {
        moment.locale('en');
        var startDate = moment(feature.start_date).utc().format('DD-MM-YYYY HH:mm');
        var endDate = moment(feature.end_date).utc().format('DD-MM-YYYY HH:mm');
        date_string = feature.end_date === null ? startDate : startDate + ' - ' + endDate
        event_container.append("<div class='event'><div class='glyphicon fa fa-calendar'></div>" + date_string + "</div>");
      }
      item.find('.category-names').append(feature.properties.category_names);
      item.find('.edit-place').attr('place_id', feature.id);
      item.find('.delete-place').attr('place_id', feature.id);
      jQuery('.places-list-accordion').append(item);
    };

    jQuery('body').on('click', '.show-map', function() {
      hideSidepanel();
    });

    // LIVE SEARCH
    jQuery('.category-input')
      .on('awesomplete-selectcomplete', function() {
        loadAndFilterPlaces();
      })

    .on('input', function(){
      var timeout;
      if (timeout !== undefined) {
        clearTimeout(timeout);
      } else {
        timeout = setTimeout(function () {
          loadAndFilterPlaces();
        }, 350);
      }
    });

    jQuery('.empty-text-filter').click(function() {
      jQuery('.category-input').val('');
      loadAndFilterPlaces();
    });

    jQuery('.filter-date-row').hide();

    jQuery('.show-events-toggle').click(function() {
      filter = jQuery(this)[0].checked;
      if (filter === true) {
        var dateRange = window.event_date_range.split(',');
        var startDate = moment(dateRange[0]).utc();
        var endDate = moment(dateRange[1]).utc();
        var dateString = endDate === null ? startDate : startDate + ' - ' + endDate;

        jQuery('.filter-date-row').show();
        jQuery('#search-date-input').daterangepicker({
          "startDate": startDate,
          "endDate": endDate,
          "showDropdowns": true,
          "showWeekNumbers": true,
          "timePicker": true,
          "timePicker24Hour": true,
          "timePickerIncrement": 15,
          "locale": { "format": 'DD.MM.YYYY HH:mm' }
        }).on('apply.daterangepicker', function() {
          loadAndFilterPlaces();
        });
      } else {
        jQuery('.filter-date-row').hide();
      }
      loadAndFilterPlaces();
      resizeSidePanel();
    });

    jQuery('.show-places-toggle').click(function() {
      loadAndFilterPlaces();
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
        loadAndFilterPlaces();
        showMapElements();
        jQuery('.loading').hide();
        showSidepanel();
        resizeSidePanel();
        hideSidepanel();
      }
    });
  });


  // MAP CONTROLS
  function fit_to_bbox() {
    if (cluster.getLayers().length > 0) {
      map.fitBounds(cluster.getBounds());
    }
  }

  // Reset view to bbox of current place selection
  jQuery('.zoom-to-bbox').on('click', function() {
    fit_to_bbox();
  });


  // Show / Hide geolocation
  function zoomTo(lat, lon) {
    map.setView([lat, lon], 18);
  }

  jQuery('.toggle-show-geolocation').on('click', function() {
    function showPosition(position) {
      lat = position.coords.latitude;
      lon = position.coords.longitude;
      current_location = L.marker([lat, lon], {icon: current_position_icon}).addTo(map);
      L.DomUtil.addClass(current_location._icon, 'current_location_marker');
      map.current_location = current_location;
      jQuery('.toggle-show-geolocation').toggleClass('inactive');

      // Zoom in if no POIs on map
      if (cluster.getLayers().length === 0) {
        zoomTo(lat, lon);
      }
    }

    function getAndShowPosition(){
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition);
      } else {
        alert('Geolocation is not supported by this browser.');
      }
    }

    if (map.current_location === undefined) {
      getAndShowPosition();
    } else {
      map.removeLayer(map.current_location);
      jQuery('.current_location_marker').remove();
      map.current_location = undefined;
      jQuery('.toggle-show-geolocation').toggleClass('inactive');
    }
  });


  // Toggle map info modal
  jQuery('.show-map-description').on('click', function() {
    jQuery('.map-description-modal').modal().show();
  });

  jQuery('.control-button[tray]').on('click', function(){
    jQuery('.right-sidebar-tray').hide();
    var trayName = jQuery(this).attr('tray');
    var tray = jQuery(trayName);
    var trayClosed = tray.hasClass('closed');

    if (trayClosed) {
      tray.removeClass('closed').show();
    } else {
      tray.addClass('closed').hide();
    }
  });

  jQuery('.select-tile-layer').on('click', function(){
    var url = jQuery(this).data('url');
    var attr = jQuery(this).data('attr');
    oldLayer = map.baseLayer;
    map.baseLayer = L.tileLayer(url, {attribution: attr});
    map.addLayer(map.baseLayer);
    map.removeLayer(oldLayer);
    jQuery('.tile-layers').toggleClass('hidden');
  });

  jQuery(this).on('click', '#map', function() {
    hideMapTrays();
  });
});
