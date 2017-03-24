jQuery(function() {
  var addMap = function(map, url) {
    baselayer = L.tileLayer(url, {attribution: '&copy; <a href="https://osm.org/copyright">OpenStreetMap</a> contributors'});
    map.addLayer(baselayer);
    map.setView([52.513, 13.4], 12);
  };

  addEsriMap = function() {
    map = L.map('map', {
      zoomControl: false,
      minZoom: 5,
      maxZoom: 18
    });

    $.ajax({
      url: 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/1/1/1.jpg',
      success: function(result) {
        addMap(map, 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.jpg');
      },
      error: function(result) {
        addMap(map, 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png');
      }
    });
  };
});
