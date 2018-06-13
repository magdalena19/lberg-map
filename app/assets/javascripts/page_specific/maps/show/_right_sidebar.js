// RIGHT SIDEBAR FUNCTIONALITY

jQuery(function() {
  // MAP CONTROL BUTTONS
  var current_position_icon = L.icon({
    iconUrl: marker_current_position
  });

  // Zoom buttons
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

  // Show places index
  jQuery('.show-places-index').on('click', function() {
    jQuery('#places-index').modal('show');
    var searchField = jQuery('#places_filter').find('input');
    var dataList = $('.search-input').find('input').data('list');

    searchField.
      detach().appendTo('#search_area').
      addClass('form-control category-input col-xs-12').
      attr('placeholder', 'Search').
      data('list', dataList)
  });


  // --- PLACE INSERT BUTTONS
  // INSERT CONFIRMATION ACTION
  function setViewAndMarkWithDot(lat, lon) {
    map.setView([lat, lon], 18);
    if (locationMarker) {
      map.removeLayer(locationMarker);
    }
    locationMarker = L.circleMarker([lat, lon]).addTo(map);
  };

  var locationMarker;

  function confirmPlaceInsert(lat, lon, geocoding_result) {
    setViewAndMarkWithDot(lat, lon);
    // confirmation button
    jQuery('.confirmation-button-container').fadeIn();
    var removeConfirmationButtons = function() {
      map.off('click', confirmClickEvent)
      jQuery('.confirmation-button-container').fadeOut();
      map.removeLayer(locationMarker);
      jQuery('.leaflet-container').css('cursor', 'inherit');
      showMapElements();
    };

    jQuery('#confirmation-button-yes').unbind('click').click(function() {
      removeConfirmationButtons();

      var address = {latitude: lat, longitude: lon};
      if (geocoding_result) {
        jQuery.extend(address, geocoding_result.properties.address);
        hideAddressSearchBar();
      }

      // Generate URL
      url = '/' + window.map_token + '/places/new?';

      // Generate URL
      jQuery.each(address, function(prop) {
        url += prop + '=' + address[prop] + '&';
      });

      jQuery.ajax({ url: url + 'remote=true' });
    });

    // cancel button
    jQuery('#confirmation-button-no').click(function() {
      removeConfirmationButtons();
      fit_to_bbox();
    });
  }

  // Whats gonna happen after selecting target point on map?
  function confirmClickEvent(point) {
    confirmPlaceInsert(point.latlng.lat, point.latlng.lng);
  }

  // INSERT PLACE MANUALLY
  jQuery('.add-place-manually').on('click', function() {
    jQuery.ajax({ url: '/' + window.map_token + '/places/new?remote=true' });
  });

  // ADD PLACE VIA ONCLICK
  jQuery('.add-place-via-click').click(function(){
    hideMapElements();
    jQuery('.leaflet-container').css('cursor','crosshair');
    map.on('click', confirmClickEvent);
  });


  // ADD PLACE VIA CURRENT GEOLOCATION
  jQuery('.add-place-via-location').click(function(){
    hideMapElements();
    jQuery('.leaflet-container').css('cursor','crosshair');
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
      hideMapElements();
      jQuery('.leaflet-overlay-pane').css('cursor','crosshair');
      confirmPlaceInsert(lat, lon, geocoding_result);
      map.on('click', confirmClickEvent);
    };
  });

  // ADDRESS SEARCH ONLY
  jQuery('.search-address').on('click', function() {
    hideMapElements();

    geocode_field = L.Control.geocoder({
      position: 'bottomright',
      collapsed: false
    }).addTo(map);

    showAddressSearchBar();

    geocode_field.markGeocode = function(geocoding_result) {
      lat = geocoding_result.properties.lat;
      lon = geocoding_result.properties.lon;
      // display marker
      setViewAndMarkWithDot(lat, lon);
      hideAddressSearchBar();
      showMapElements();
    };
  });

  jQuery('.fade-background').on('click', function() {
    hideAddressSearchBar();
    showMapElements();
  });

  // Reset view to bbox of current place selection
  function fit_to_bbox() {
    if (cluster.getLayers().length > 0) {
      map.fitBounds(cluster.getBounds());
    }
  }

  jQuery('.zoom-to-bbox').on('click', function() {
    fit_to_bbox();
  });

  // Show / Hide geolocation
  jQuery('.show-current-position-toggle').on('click', function() {
    function showPosition(position) {
      lat = position.coords.latitude;
      lon = position.coords.longitude;
      current_location = L.marker([lat, lon], {icon: current_position_icon}).addTo(map);
      map.current_location = current_location;
      L.DomUtil.addClass(current_location._icon, 'current_location_marker');
      jQuery('.toggle-show-geolocation').toggleClass('inactive');

      // Zoom in if no POIs on map
      if (cluster.getLayers().length === 0) {
        map.setView([lat, lon], 18);
      }
    }

    function getAndShowPosition(){
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition);
      } else {
        alert('Geolocation is not supported by this browser.');
      }
    }

    var shallDisplayPos= jQuery('.show-current-position-toggle')[0].checked;
    if (shallDisplayPos) {
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
    var toggleHeight = jQuery(this).height();

    if (trayClosed) {
      tray.removeClass('closed').show();
      var trayHeight = tray.height();
      var topPos = jQuery(this).children().offset().top - trayHeight + toggleHeight;
      tray.offset({top: topPos});
    } else {
      tray.addClass('closed').hide();
    }
  });

  // Toggle tile layer selection
  jQuery('.select-tile-layer').on('click', function(){
    var url = jQuery(this).data('url');
    var attr = jQuery(this).data('attribution');
    oldLayer = map.baseLayer;
    map.baseLayer = L.tileLayer(url, {attribution: attr});
    map.addLayer(map.baseLayer);
    map.removeLayer(oldLayer);
    jQuery('.tile-layers').toggleClass('hidden');
  });

  jQuery(this).on('click', '#map', function() {
    hideMapTrays();
  });
})
