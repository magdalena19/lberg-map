//= require map_base
//= require_self
//= require ./embedding
//= require ./show/_right_sidebar
//= require ./show/_map_overlays

jQuery(function() {
  // Marker icons
  function icon(markerColor, iconClass, iconShape, reviewed) {
    return L.ExtraMarkers.icon({
      prefix: 'fa',
      icon: iconClass,
      shape: iconShape,
      markerColor: markerColor,
      extraClasses: reviewed ? '' : 'unreviewed-marker'
    });
  }

  function checkLocaleSupport() {
    var currentLocale = window.locale;
    var supportedLocales = window.map_languages;

    if(supportedLocales.indexOf(currentLocale) === -1){
      $('.select-other-locale').modal({
        show: true,
        backdrop: 'static',
        keyboard: false
      });
    }
  }

  jQuery('#map').each(function() {
    // move static flash message in foreground when map is displayed
    jQuery('.flash-message').css('position', 'absolute').css('z-index', '999999');

    // Display map description on visit if set so...
    console.log(mayShowMapDescription)
    if (window.mayShowMapDescription) {
      showMapDescription();
    }

    checkLocaleSupport();

    addEsriMap([0, 0], 3);

    var highlightedLayer;
    var onEachFeature = function(feature, layer) {
      layer.highlight = function() {
        if (highlightedLayer) {
          var props = highlightedLayer['props'];
          highlightedLayer['layer'].setIcon(icon(props.marker_color, props.marker_icon_class, props.marker_shape, props.reviewed === true));
        }
        highlightedLayer = {layer: layer, props: prop};
        layer.setIcon(icon('black', prop.marker_icon_class, prop.marker_shape, prop.reviewed === true));
        map.setView([feature.geometry.coordinates[1], feature.geometry.coordinates[0]], map.getZoom());
      };

      addToPlacesList(feature, layer);
      var prop = feature.properties;
      layer.setIcon(icon(prop.marker_color, prop.marker_icon_class, prop.marker_shape, 'white', prop.reviewed === true));

      layer.on('click', function(e) {
        showPlacesListPanel();
        resizeSidePanel();

        var accordionItemHeading = jQuery('#heading' + feature.id);
        if (accordionItemHeading.hasClass('collapsed')) {
          accordionItemHeading.click();
          var list = jQuery('.places-list-panel');
          list.scrollTo(accordionItemHeading, {
            offset: -5
          });
        }
      });
    };

    jQuery('.places-list-panel')
      .on('click', '.zoom-to-place', function() {
        var lat = jQuery(this).attr('lat');
        var lon = jQuery(this).attr('lon');
        var latlng = {'lat': lat, 'lon': lon}
        map.setView(latlng, Math.max(map.getZoom(), 16));
        if ($(document).width() < 600) { hidePlacesListPanel(); };
      });

    // do not use the simpler .click function due to dynamic creation
    jQuery('body').on('click', '.edit-place', function() {
      var placeId = jQuery(this).attr('place_id');
      var url = '/' + window.map_token + '/places/' + placeId + '/edit';
      jQuery.ajax({
        url: url + '?remote=true'
      });
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

      if (json.length == 0) {
        jQuery('.places-list-accordion').append('No places yet!')
      };

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
        pointToLayer: function(feature, latlng) {
          return L.marker(latlng, {
            icon: icon
          });
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
          if (string.indexOf(word) >= 0) {
            match = true;
            return false; // return false to quit loop
          }
        });
      });
      return match;
    };

    var textFilter = function(json) {
      var text = jQuery('#search-input').val();
      if (!text) {
        return json;
      }

      var filteredJson = [];
      var wordGroups = text.
        replace(';', ',').
        replace(', ', ',').
        split(',').
        filter(Boolean);

      // Parse every json element for occurences of separated search string
      jQuery(json).each(function(id, feature) {
        var matches = jQuery.map(wordGroups, function(wordGroup) {
          return wordPresent(wordGroup, feature);
        });
        if (matches.every(function(match) {
          return match === true
        })) {
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
      if (!showEvents()) {
        return json;
      } else {
        var filteredJson = [];

        // Iterate features and push on filter match
        var daterange = jQuery('#search-date-input').data('daterangepicker');
        var startDate = forceUTC(daterange.startDate);
        var endDate = forceUTC(daterange.endDate);

        jQuery(json).each(function(id, feature) {
          var featureStartDate = moment(feature.start_date);
          var featureEndDate = moment(feature.end_date);

          if (
            (featureStartDate >= startDate && featureStartDate <= endDate) ||
            (featureEndDate >= startDate && featureEndDate <= endDate) ||
            (!feature.is_event && showPlaces())
          ) {
            filteredJson.push(feature);
          }
        });
        return filteredJson;
      }
    };

    // PLACE TYPE FILTER
    function showFeature(feature) {
      if ((feature.is_event && showEvents()) || (!feature.is_event && showPlaces())) {
        return true;
      } else {
        return false;
      }
    }

    var placeTypeFilter = function(json) {
      var filteredJson = [];
      jQuery(json).each(function(id, feature) {
        if (showFeature(feature)) {
          filteredJson.push(feature);
        }
      });
      return filteredJson;
    };

    var loadAndFilterPlaces = function() {
      updatePlaces(dateFilter(textFilter(placeTypeFilter(window.places))), {
        fitBounds: true
      });
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
      panel.css('top', filterField.outerHeight() + navbarHeight);
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

    jQuery(window).resize(function() {
      resizeSidePanel();
    }).resize();


    // TOGGLE SIDEPANEL
    jQuery('.toggle-panel').click(function() {
      if (jQuery('.places-list-panel').is(':visible')) {
        hidePlacesListPanel();
        showMapControls();
      } else {
        showPlacesListPanel();
        if (window.innerWidth < 600) {
          hideMapControls()
        };
      }
    });

    // FILL PLACES LIST

    // Add places to places side panel
    var addToPlacesList = function(feature, layer) {
      var item = jQuery('.places-list-item.template').clone();
      var contact = item.find('.contact-container');
      var event_container = item.find('.event-container');
      var panelType = feature.is_event ? 'event-panel' : 'place-panel';

      item.removeClass('template');
      item.find('.panel-heading').addClass(panelType);
      item.find('.panel-heading')
        .attr('id', 'heading' + feature.id)
        .attr('href', '#collapse' + feature.id)
        .attr('aria-controls', 'collapse' + feature.id)
        .attr('lon', feature.geometry.coordinates[0])
        .attr('lat', feature.geometry.coordinates[1]);
      item.find('.panel-heading').click(function() { layer.highlight() });

      item.find('.name').html(feature.properties.name);
      // if (feature.is_event === true) {
      //   item.find('.place_type').addClass('fa fa-calendar ' + panelType);
      // } else {
      //   item.find('.place_type').addClass('fa fa-home ' + panelType);
      // }
      item.find('.list-item-category')
        .addClass('fa ' + feature.properties.marker_icon_class)
        .addClass(feature.properties.marker_color);

      item.find('.panel-collapse')
        .attr('id', 'collapse' + feature.id)
        .attr('aria-labelledby', 'heading' + feature.id);
      item.find('.description').append(feature.properties.description);


      // Add place information sub-panels
      if (feature.properties.address !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-record'></div>" + feature.properties.address + "</div>");
      }
      if (feature.properties.phone !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-earphone'></div>" + feature.properties.phone + "</div>");
      }
      if (feature.properties.email !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-envelope'></div>" + feature.properties.email + "</div>");
      }
      if (feature.properties.homepage !== '') {
        contact.append("<div class='item-panel " + panelType + "'><div class='glyphicon glyphicon-home'></div>" + feature.properties.homepage + "</div>");
      }
      if (feature.start_date !== null) {
        moment.locale('en');
        var startDate = moment(feature.start_date).utc().format('DD-MM-YYYY HH:mm');
        var endDate = moment(feature.end_date).utc().format('DD-MM-YYYY HH:mm');
        date_string = feature.end_date === null ? startDate : startDate + ' - ' + endDate;
        event_container.append("<div class='event'><div class='glyphicon fa fa-calendar'></div>" + date_string + "</div>");
      }
      item.find('.category-names').append(feature.properties.category_names);
      item.find('.zoom-to-place').attr('lon', feature.geometry.coordinates[0]).attr('lat', feature.geometry.coordinates[1]);
      item.find('.edit-place').attr('place_id', feature.id);
      item.find('.delete-place').attr('place_id', feature.id);

      if (feature.properties.reviewed === false) {
        item.css('opacity', '0.6');
        item.find('.edit-place').hide();
      };

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

      .on('input', function() {
        var timeout;
        if (timeout !== undefined) {
          clearTimeout(timeout);
        } else {
          timeout = setTimeout(function() {
            loadAndFilterPlaces();
          }, 350);
        }
      });

    jQuery('.empty-text-filter').click(function() {
      jQuery('.category-input').val('');
      loadAndFilterPlaces();
    });

    // Place toggling
    function showPlaces() {
      var placesToggle = jQuery('.show-places-toggle')[0];
      return placesToggle && placesToggle.checked;
    }

    // Event toggling
    function showEvents() {
      var eventsToggle = jQuery('.show-events-toggle')[0];
      return eventsToggle && eventsToggle.checked;
    }

    function eventDateRange() {
      var dateRange = window.event_date_range.split(',');
      var startDate = moment(dateRange[0], 'YYYY-MM-DD hh:mm:ss').utc();
      var endDate = moment(dateRange[1], 'YYYY-MM-DD hh:mm:ss').utc();
      return {
        'startDate': startDate,
        'endDate': endDate
      };
    }

    function appendDateRangePicker() {
      jQuery('#search-date-input').daterangepicker({
        "showWeekNumbers": true,
        "timePicker": true,
        "timePicker24Hour": true,
        "timePickerIncrement": 15,
        ranges: {
          'Today': [moment(), moment()],
          'This Week': [moment().startOf('week').add(1, 'days'), moment().endOf('week').add(1, 'days')], // Dirty correct for english style start of week
          '+-15 Days': [moment().subtract(15, 'days'), moment().add(15, 'days')],
          'This Month': [moment().startOf('month'), moment().endOf('month')]
          // 'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
          // 'Last 7 Days': [moment().subtract(6, 'days'), moment()],
          // 'Last 30 Days': [moment().subtract(29, 'days'), moment()],
          // 'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        },
        "locale": {
          "format": 'DD.MM.YYYY HH:mm'
        }
      }).on('apply.daterangepicker', function() {
        loadAndFilterPlaces();
      });
    }


    // Initially feed correct date range of all events if events are to be shown
    if (showEvents()) {
      appendDateRangePicker();
    }

    jQuery('.show-events-toggle').on('change', function() {
      if (showEvents()) {
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
    jQuery.when($.ajax({
      url: '/needs_unlock',
      data: {
        map_token: window.map_token
      }
    })).then(function(data) {
      if (data.needs_unlock) {
        showPasswordPrompt();
      } else {
        jQuery('.map-password-dialog').modal('hide');
        getPois();
      }
    });

    // PROMPT FOR MAP PASSWORD
    function showPasswordPrompt() {
      function validatePassword(){
        var password = jQuery('.password-input').val();

        jQuery.ajax({
          url: '/' + window.map_token + '/unlock',
          data: {
            password: password
          },
          dataType: 'script',
          success: function() {
            getPois()
            jQuery('.map-password-dialog').modal('hide');
          },
          error: function() {
            jQuery('.error-message').append('<div role="alert" class="alert alert-danger flash-message">Wrong password</div>');
            jQuery('.error-message .flash-message').delay(3000).fadeOut(800);
          }
        });
      }

      jQuery('.map-password-dialog').each(function(){
        $('.password-input').focus();
      })

      jQuery('.unlock').on('click', function() {
        validatePassword();
      });

      $('.password-input').keyup(function(event) {
        if (event.keyCode === 13) {
          validatePassword();
        }
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
        success: function(response) {
          window.places = response.places;
          window.categories = response.categories;
          initCategoryInput(window.categories);
          loadAndFilterPlaces();
          showMapElements();
          jQuery('.loading').hide();
          jQuery('.fade-background').hide();
          showPlacesListPanel();
          resizeSidePanel();
          hidePlacesListPanel();
          activateDateFilterIfEventsPresent(window.places);
        }
      });
    }

    // UPDATE CONTENT AFTER POI MANIPULATION
    function flashResults(message) {
      jQuery('.map-flash').text(message).show().delay(4000).fadeOut(4000);
    }

    function displayFormErrors(message) {
      var flashMessage = '<div role="alert" class="alert alert-danger flash-message">' + message + '</div>';
      jQuery('.modal-body').prepend(flashMessage);
      jQuery('.modal').scrollTo('.alert', {
        offset: -10
      });
    }

    jQuery(document).ajaxComplete(function(event, xhr, settings) {
      var response = xhr.responseJSON;
      if (['POST', 'DELETE'].indexOf(settings.type) != -1) {
        if (xhr.status == 200) {
          jQuery('.modal').modal('hide');
          window.places = response.places;
          window.categories = response.categories;
          updatePlaces(dateFilter(textFilter(placeTypeFilter(window.places))));
          flashResults(response.message);
          if (response.coordinates) {
            map.panTo(response.coordinates)
          };
          initCategoryInput(window.categories);
          activateDateFilterIfEventsPresent(window.places);
        } else {
          displayFormErrors(xhr.responseText) // Assume form error if response != 200
        }
      };
    });
  });

  function activateDateFilterIfEventsPresent(places) {
    jQuery('.show-events-toggle')
      .prop('checked', containsEvent(window.places))
      .change();
  };

  function containsEvent(places) {
    var found = false;
    for(var i = 0; i < places.length; i++) {
      if (places[i].is_event) { found = true; break; }
    }
    return found;
  };

  function fit_to_bbox() {
    if (cluster.getLayers().length > 0) {
      map.fitBounds(cluster.getBounds());
    }
  }
});
