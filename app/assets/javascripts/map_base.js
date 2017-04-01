//= require leaflet
//= require leaflet.markercluster

jQuery(function() {
  var MAIN_TILE_SERVER_TEST = 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/1/1/1.jpg';
  var MAIN_TILE_SERVER = 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.jpg';
  var FALLBACK_TILE_SERVER = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  var addMap = function(map, url, center, zoom) {
    baselayer = L.tileLayer(url, {attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors'});
    map.addLayer(baselayer);
    map.setView(center, zoom);
  };

  addEsriMap = function(center, zoom) {
    map = L.map('map', {
      zoomControl: false,
      minZoom: 5,
      maxZoom: 18
    });

    $.ajax({
      url: MAIN_TILE_SERVER_TEST,
      success: function(result) {
        addMap(map, MAIN_TILE_SERVER, center, zoom);
      },
      error: function(result) {
        addMap(map, FALLBACK_TILE_SERVER, center, zoom);
      }
    });
  };
});
