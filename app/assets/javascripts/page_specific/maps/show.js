//= require map_base
//= require ./_map_overlays

jQuery(function() {
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
        layer.setIcon(session_icon);
      }
      layer.on('click', function(e) {
        showSidepanel();
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

    jQuery('body').on('click', '.delete-place', function() {
      var placeId = jQuery(this).attr('place_id');
      var panel = jQuery('#heading' + placeId).parent();
      var confirm_delete = confirm(window.delete_confirmation_text);

      if (confirm_delete == true) {
        jQuery.ajax({
          url: '/' + window.map_token + '/places/' + placeId,
          type: 'DELETE',
          success: function(result) {
            panel.fadeOut(350, function() { jQuery(this).remove() });
          }
        });
      }
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
      map.fitBounds(cluster.getBounds());
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
      var daterange = jQuery('#search-date-input').data('daterangepicker');
      var startDate = forceUTC(daterange.startDate);
      var endDate = forceUTC(daterange.endDate);
      if (!jQuery('#search-date-input').is(':visible')) { return json; }
      var filteredJson = [];
      jQuery(json).each(function (id, feature) {
        var featureStartDate = moment(feature.start_date);
        var featureEndDate = moment(feature.end_date);
        if (
          ( featureStartDate >= startDate && featureStartDate <= endDate ) ||
          ( featureEndDate >= startDate && featureEndDate <= endDate )
        ) {
          filteredJson.push(feature);
        }
      });
      return filteredJson;
    };

    var loadAndFilterPlaces = function() {
      updatePlaces(dateFilter(textFilter(window.places)));
    };

    // ADD PLACE
    jQuery('.add-place-button').click(function() {
      showSidepanel();
      jQuery('.sidepanel-button-container').hide();
      jQuery('.sidepanel-add-place-container').show();
      resizeSidePanel();
    });

    jQuery('.cancel-place-addition').click(function() {
      jQuery('.sidepanel-add-place-container').hide();
      jQuery('.sidepanel-default-container').show();
      resizeSidePanel();
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
        showSidepanel();
      });
    }

    // Google geolocation API not working properly, so freeze this feature
    jQuery('.add-place-via-location').click(function(){
      hideSidepanel();
      function confirmation(position) {
        confirmPlaceInsert(position.coords.latitude, position.coords.longitude);
      }

      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(confirmation);
      } else {
        console.log('Geolocation is not supported by this browser.');
      }
    });

    jQuery('.add_place_via_click').click(function(){
      hideSidepanel();
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
      var panel = jQuery('.places-list-panel');
      var accordion = jQuery('.places-list-accordion-container');
      var searchField = jQuery('.search-field');
      var buttons = jQuery('.button-container');
      var toggle = jQuery('.toggle-panel');
      accordion.height(panel.height() - searchField.outerHeight() - buttons.outerHeight() - 30);
      if (jQuery('.places-list-panel').is(':visible')) {
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

      item.removeClass('template');
      item.find('.panel-heading').attr('id', 'heading' + feature.id);
      item.find('a')
        .attr('href', '#collapse' + feature.id)
        .attr('aria-controls', 'collapse' + feature.id)
        .attr('lon', feature.geometry.coordinates[0])
        .attr('lat', feature.geometry.coordinates[1]);
      item.find('.name').html(feature.properties.name);
      if (feature.is_event === true) {
        item.find('.place_type').addClass('glyphicon-calendar');
      } else {
        item.find('.place_type').addClass('glyphicon-home');
      }
      item.find('.panel-collapse')
        .attr('id', 'collapse' + feature.id)
        .attr('aria-labelledby', 'heading' + feature.id);
      item.find('.description').append(feature.properties.description);

      var contact = item.find('.contact-container');
      var event_container = item.find('.event-container');

      // Add place information sub-panels
      if(feature.properties.address !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-record'></div>" + feature.properties.address + "</div>");
      }
      if(feature.properties.phone !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-earphone'></div>" + feature.properties.phone + "</div>");
      }
      if(feature.properties.email !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-envelope'></div>" + feature.properties.email + "</div>");
      }
      if(feature.properties.homepage !== '') {
        contact.append("<div class='contact'><div class='glyphicon glyphicon-home'></div>" + feature.properties.homepage + "</div>");
      }
      if(feature.start_date !== null) {
        moment.locale('en');
        var startDate = moment(feature.start_date).utc().format('DD-MM-YYYY HH:mm');
        var endDate = moment(feature.end_date).utc().format('DD-MM-YYYY HH:mm');
        date_string = feature.end_date === null ? startDate : startDate + ' - ' + endDate
        event_container.append("<div class='event'><div class='glyphicon glyphicon-calendar'></div>" + date_string + "</div>");
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
        loadAndFilterPlaces();
      });

    jQuery('.empty-text-filter').click(function() {
      jQuery('.category-input').val('');
      loadAndFilterPlaces();
    });

    jQuery('#search-date-input')
      .on('apply.daterangepicker', function() {
        loadAndFilterPlaces();
      });

    jQuery('.filter-date-row').hide();
    jQuery('.cancel-date-filter').click(function() {
      jQuery('.filter-date-row').hide();
      jQuery('.add-date-filter').show();
      loadAndFilterPlaces();
    });
    jQuery('.add-date-filter').click(function() {
      jQuery('.add-date-filter').hide();
      jQuery('.filter-date-row').show();
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
      }
    });
  });
});
