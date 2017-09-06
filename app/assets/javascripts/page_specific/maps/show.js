//= require map_base
//= require ./embedding
//= require ./show/_right_sidebar
//= require ./show/_map_overlays

jQuery(function() {
  // Marker icons
  function place_icon(color) {
    return L.ExtraMarkers.icon({
      prefix: 'fa',
      icon: 'fa-home',
      markerColor: color
    });
  }

  function event_icon(color) {
    return L.ExtraMarkers.icon({
      prefix: 'fa',
      icon: 'fa-calendar',
      markerColor: color
    });
  }

  function session_event_icon(color) {
    return L.ExtraMarkers.icon({
      prefix: 'fa',
      icon: 'fa-calendar',
      shape: 'star',
      markerColor: 'black'
    });
  }

  function session_place_icon(color) {
    return L.ExtraMarkers.icon({
      prefix: 'fa',
      icon: 'fa-home',
      shape: 'star',
      markerColor: 'black'
    });
  }

  jQuery('#map').each(function() {
    // move flash message in foreground when map is displayed
    jQuery('#flash-messages').css('position', 'absolute').css('z-index', '999999');

    addEsriMap([0, 0], 3);

    // still to be used!
    var autotranslatedPrefix = "<p><i>" + window.autotranslated_label + ": </i></p>";
    var waitingForReviewSuffix = "<span style='color: #ff6666;'> | " + window.waiting_for_review_label + "</span>";

    function zoomTo(lat, lon) {
      var latlng = {'lat': lat, 'lon': lon}
      map.setView(latlng, 16);
    }

    var onEachFeature = function(feature, layer) {
      addToPlacesList(feature);
      var prop = feature.properties;
      if (prop.reviewed === false) {
        if (prop.is_event === true) {
          layer.setIcon(session_event_icon(prop.color));
        } else {
          layer.setIcon(session_place_icon(prop.color));
        }
      } else {
        if (prop.is_event === true) {
          layer.setIcon(event_icon(prop.color));
        } else {
          layer.setIcon(place_icon(prop.color));
        }
      }

      layer.on('click', function(e) {
        showPlacesListPanel();
        zoomTo(e.latlng.lat, e.latlng.lng);

        var accordionItemHeading = jQuery('#heading' + feature.id);
        var headingLink = accordionItemHeading.find('a');
        if (headingLink.hasClass('collapsed')) {
          headingLink.click();
          var list = jQuery('.places-list-panel');
          list.scrollTo(accordionItemHeading.parent(), {offset: -5});
        }
      });
    };

    jQuery('.places-list-panel').on('click', 'a', function() {
      var lat = jQuery(this).attr('lat');
      var lon = jQuery(this).attr('lon');

      zoomTo(lat, lon);
    });

    // do not use the simpler .click function due to dynamic creation
    jQuery('body').on('click', '.edit-place', function() {
      var placeId = jQuery(this).attr('place_id');
      var url = '/' + window.map_token + '/places/' + placeId + '/edit';
      jQuery.ajax({ url: url + '?remote=true' });
    });

    jQuery('body').on('click', '.delete-place', function() {
      var placeId = jQuery(this).attr('place_id');
      var confirm_delete = confirm(window.delete_confirmation_text);
      var panel = jQuery('#heading' + placeId).parent();
      var modalRow = jQuery('#places').find('#row_' + placeId);

      if (confirm_delete === true) {
        jQuery.ajax({
          url: '/' + window.map_token + '/places/' + placeId,
          type: 'DELETE',
        });
      }
    });

    var updatePlaces = function(json, options) {
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

      if (options && (options.fitBounds == true)) {
        if (json.length > 0) {
          map.fitBounds(cluster.getBounds());
          jQuery('.zoom-to-bbox').removeClass('inactive');
        } else {
          jQuery('.zoom-to-bbox').addClass('inactive');
        }
      };
    };

    // TEXT FILTER
    var wordPresent = function(wordGroup, feature) {
      var match = false;

      jQuery.each(feature.properties, function(attr, key) {
        var value = feature.properties[attr];
        var string = value ? value.toString().toLowerCase() : '';
        // Split search string again for OR search and return true if there is a match
        var words = wordGroup.split('OR');
        jQuery(words).each(function(index, word) {
          word = word.trim().toLowerCase();
          if ( string.indexOf(word) >= 0 ) {
            match = true;
            return false; // return false to quit loop
          }
        });
      });
      return match;
    };

    var textFilter = function(json) {
      var text = jQuery('#search-input').val();
      if (!text) { return json; }

      var filteredJson = [];
      var wordGroups = text.
        replace(';', ',').
        replace(', ', ',').
        split(',').
        filter(Boolean);

      // Parse every json element for occurences of separated search string
      jQuery(json).each(function (id, feature) {
        var matches = jQuery.map(wordGroups, function(wordGroup) {
          return wordPresent(wordGroup, feature);
        });
        if ( matches.every( function(match) { return match === true } ) ) {
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
      // Check if shall filter by date, pass unfiltered json if not...
      var showEventsToggle = jQuery('.show-events-toggle')[0];
      var filterByDate = showEventsToggle && showEventsToggle.checked || false;

      if ( !filterByDate ) {
        return json;
      } else {
        var filteredJson = [];

        // Iterate features and push on filter match
        var daterange = jQuery('#search-date-input').data('daterangepicker');
        var startDate = forceUTC(daterange.startDate);
        var endDate = forceUTC(daterange.endDate);
        var showPlaces = jQuery('.show-places-toggle')[0].checked;

        jQuery(json).each(function (id, feature) {
          var featureStartDate = moment(feature.start_date);
          var featureEndDate = moment(feature.end_date);

          if (
            ( featureStartDate >= startDate && featureStartDate <= endDate ) ||
            ( featureEndDate >= startDate && featureEndDate <= endDate ) ||
            ( !feature.is_event && showPlaces )
          ) {
            filteredJson.push(feature);
          }
        });
        return filteredJson;
      }
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
      updatePlaces(dateFilter(textFilter(placeTypeFilter(window.places))), {fitBounds: true});
    };

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
        if (window.innerWidth < 600) {
          hideMapControls();
        } else {
          showMapControls();
        }
      } else {
        jQuery('.toggle-panel').css('left', 0);
        showMapControls();
      }
    };

    jQuery(window).resize(function(){
      resizeSidePanel();
    }).resize();


    // TOGGLE SIDEPANEL
    jQuery('.toggle-panel').click(function() {
      if (jQuery('.places-list-panel').is(':visible')) {
        hidePlacesListPanel();
        showMapControls();
      } else {
        showPlacesListPanel();
        if (window.innerWidth < 600) { hideMapControls() };
      }
    });

    // FILL PLACES LIST
    // Return black or white as font color depending on background color
    function bestContrastFontColor(backgroundColor) {
      needsWhiteFont = ['red', 'darkorange', 'darkblue', 'purple', 'darkgreen', 'green'];
      needsBlackFont = ['orange', 'yellow', 'lightgreen', 'violet', 'pink'];

      if (needsWhiteFont.includes(backgroundColor)) {
        return('white');
      } else {
        return('black');
      }
    }

    // Add places to places side panel
    var addToPlacesList = function(feature) {
      var item = jQuery('.places-list-item.template').clone();
      var contact = item.find('.contact-container');
      var event_container = item.find('.event-container');
      var panelType = feature.is_event ? 'event-panel' : 'place-panel';

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
        date_string = feature.end_date === null ? startDate : startDate + ' - ' + endDate;
        event_container.append("<div class='event'><div class='glyphicon fa fa-calendar'></div>" + date_string + "</div>");
      }
      item.find('.category-names').append(feature.properties.category_names);
      item.find('.edit-place').attr('place_id', feature.id);
      item.find('.delete-place').attr('place_id', feature.id);
      jQuery('.places-list-accordion').append(item);
    };

    jQuery('body').on('click', '.show-map', function() {
      hidePlacesListPanel();
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


    // Evente toggling
    function showEvents() {
      return jQuery('.show-events-toggle')[0].checked;
    }

    function eventDateRange() {
      var dateRange = window.event_date_range.split(',');
      var startDate = moment(dateRange[0]).utc();
      var endDate = moment(dateRange[1]).utc();

      return {'startDate': startDate, 'endDate': endDate};
    }

    function appendDateRangePicker() {
      jQuery('#search-date-input').daterangepicker({
        "startDate": eventDateRange().startDate,
        "endDate": eventDateRange().endDate,
        "showDropdowns": true,
        "showWeekNumbers": true,
        "timePicker": true,
        "timePicker24Hour": true,
        "timePickerIncrement": 15,
        "locale": { "format": 'DD.MM.YYYY HH:mm' }
      }).on('apply.daterangepicker', function() {
        loadAndFilterPlaces();
      });
    }


    // Initially feed correct date range of all events if events are to be shown
    if ( showEvents() ) {
      appendDateRangePicker();
    }

    jQuery('.show-events-toggle').click(function() {
      if ( showEvents() ) {
        jQuery('.filter-date-row').show();
        appendDateRangePicker();
      } else {
        jQuery('.filter-date-row').hide();
      }
      loadAndFilterPlaces();
      resizeSidePanel();
    });

    jQuery('.show-places-toggle').click(function() {
      loadAndFilterPlaces();
    });

    hideMapElements();

    // CHECK IF MAP IS LOCKED VIA PASSWORD
    jQuery.when( $.ajax( {
      url: '/needs_unlock',
      data: { map_token: window.map_token }
    }) ).then( function(data) {
      if (data.needs_unlock) {
        showPasswordPrompt();
      } else {
        jQuery('.map-password-dialog').modal('hide');
        getPois();
      }
    });

    // PROMPT FOR MAP PASSWORD
    function showPasswordPrompt() {
      jQuery('.map-password-dialog').modal().show;
      jQuery('.unlock').on('click', function() {
        var password = jQuery('.password-input').val();

        jQuery.ajax({
          url: '/' + window.map_token + '/unlock',
          data: { password: password },
          dataType: 'script',
          success: function() {
            getPois()
            jQuery('.map-password-dialog').modal('hide');
          },
          error: function() {
            var errorMessage = '<div role="alert" class="alert alert-danger" id="flash-messages">Wrong password</div>'
            jQuery('.error-messages').append(errorMessage);
            jQuery('.error-messages #flash-messages').delay(3000).fadeOut(800).promise().done(function() {
              jQuery(this).remove();
            });
          }
        });
      });
    }

    // RECEIVE POIS
    jQuery('.fade-background').show();
    function getPois() {
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
          jQuery('.fade-background').hide();
          showPlacesListPanel();
          resizeSidePanel();
          hidePlacesListPanel();
        }
      });
    }

    // UPDATE CONTENT AFTER POI MANIPULATION
    jQuery(document).ajaxComplete(function( event, xhr, settings ) {
      var response = xhr.responseJSON;
      if (['POST', 'DELETE'].includes(settings.type)) {
        if ([200, 201].includes(xhr.status)) {
          if (xhr.status == 200) {
            var alertText = 'Successfully updated!'
          } else if (xhr.status == 201) {
            var alertText = 'Successfully created!'
          };
          jQuery('.modal').modal('hide');
          window.places = response.places;
          updatePlaces(dateFilter(textFilter(placeTypeFilter(window.places))));
          var errorMessage = '<div role="alert" class="alert alert-danger" id="flash-messages">' + response.success_message + '</div>';
          map.panTo(response.coordinates);
          jQuery('.map-flash').html(errorMessage).show().fadeOut(4000);
        } else {
          var errorMessage = '<div role="alert" class="alert alert-danger" id="flash-messages">' + xhr.responseText + '</div>';
          jQuery('.modal-body').prepend(errorMessage);
        }
      };
    });
  });

  function fit_to_bbox() {
    if (cluster.getLayers().length > 0) {
      map.fitBounds(cluster.getBounds());
    }
  }
});
