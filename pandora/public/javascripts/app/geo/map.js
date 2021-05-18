document.observe("dom:loaded", function() {
  // https://developer.mapquest.com/documentation/mapquest-js/v1.3/
  L.mapquest.key = '6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ';

  map = L.mapquest.map('map', {
    center: [lat, lng],
    layers: L.mapquest.tileLayer('map'),
    zoom: zoom_level
  });

  // http://leafletjs.com/reference.html
  marker = L.marker([lat, lng], {
  }).addTo(map);
});
