//= require leaflet
//= require leaflet.draw
//= require leaflet.markercluster
//= require leaflet-providers
//= require Control.Geocoder
//= require leaflet.extra-markers.min

jQuery(function() {
  var MAIN_TILE_SERVER_TEST = 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/1/1/1.jpg';
  var MAIN_TILE_SERVER = 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.jpg';
  var FALLBACK_TILE_SERVER = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  var addMap = function(map, url, center, zoom) {
    map.baseLayer = L.tileLayer(url, {attribution: 'Source: Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community'});
    map.addLayer(map.baseLayer);
    map.setView(center, zoom);
  };

  addEsriMap = function(center, zoom) {
    map = L.map('map', {
      zoomControl: false,
      minZoom: 3,
      maxZoom: 18
    });

    jQuery.ajax({
      url: MAIN_TILE_SERVER_TEST,
      success: function(result) {
        addMap(map, MAIN_TILE_SERVER, center, zoom);
      },
      error: function(result) {
        addMap(map, FALLBACK_TILE_SERVER, center, zoom);
      }
    });
  };
})
