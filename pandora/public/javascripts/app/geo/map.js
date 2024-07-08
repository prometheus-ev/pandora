document.observe("dom:loaded", function() {
  // http://leafletjs.com/reference.html
  map = L.map('map', {
    center: [lat, lng],
    zoom: zoom_level
  });

  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);

  var markerIcon = L.icon({
    iconUrl: '/images/icon/google_maps.png',
    iconSize: [32, 32],
  });

  marker = L.marker([lat, lng], {
    icon: markerIcon
  }).addTo(map);
});
