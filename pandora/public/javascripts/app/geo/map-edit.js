var map = null;
var marker = null;

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
    draggable: true
  }).addTo(map);

  if (lat === lat_default && lng === lng_default) {
    marker.setOpacity(0);
  }

  $('upload-location-search-result').hide();

  Element.observe(document, 'click', function(event) {
    $('upload-location-search-result').hide();
  });

  var i_default = -1;
  var i = i_default;

  Element.observe('upload_location', 'keyup', function(event) {
    var key = event.which || event.keyCode;
    var list_items = $('upload-location-search-result').childElements();
    switch (key) {
      case Event.KEY_ESC:
        $('upload-location-search-result').hide();
        i = i_default;
        break;
      case Event.KEY_UP:
        if (i < list_items.length) {
          $('upload-location-search-result').scrollTop -= Element.getHeight(list_items[i]);
          list_items[i].setStyle({ backgroundColor: '#262626' });
        }
        if (i > -1) {
          i--;
          list_items[i].setStyle({ backgroundColor: '#FF9933' });
          eval(list_items[i].readAttribute('onmouseover'));
        }
        break;
      case Event.KEY_DOWN:
        if (i > -1 && i < (list_items.length - 1)) {
          $('upload-location-search-result').scrollTop += Element.getHeight(list_items[i]);
          list_items[i].setStyle({ backgroundColor: '#262626' });
        }
        if (i < (list_items.length - 1)) {
          i++;
          list_items[i].setStyle({ backgroundColor: '#FF9933' });
          eval(list_items[i].readAttribute('onmouseover'));
        }
        break;
      case Event.KEY_RETURN:
        eval(list_items[i].readAttribute('onclick'));
        Event.stop(event);
        break;
      default:
        $('upload-location-search-result').hide();
        request_location_with($('upload_location').value);
        i = i_default;
        break;
    }
  });

  Element.observe('upload_location', 'keydown', function(event) {
    var key = event.which || event.keyCode;
    var list_items = $('upload-location-search-result').childElements();
    switch (key) {
      case Event.KEY_RETURN:
        eval(list_items[i].readAttribute('onclick'));
        Event.stop(event);
        break;
      default:
        break;
    }
  });

  Element.observe('upload_location', 'click', function(event) {
    $('upload-location-search-result').hide();
    request_location_with($('upload_location').value);
    i = i_default;
  });

  marker.on('dragstart', function(e) {
    $('upload-location-search-result').hide();
  });

  marker.on('drag', function(e) {
    lat_lng = marker.getLatLng();
    $('upload_latitude').value = lat_lng.lat.toFixed(5);
    $('upload_longitude').value = lat_lng.lng.toFixed(5);
  });

  marker.on('dragend', function(e) {
    lat_lng = marker.getLatLng();
    request_location_by(lat_lng.lat.toFixed(5), lat_lng.lng.toFixed(5));
    zoom_level = map.getZoom();
  });

  map.on('zoomend', function(e) {
    zoom_level = map.getZoom();
  });

  map.on('click', function(e) {
    marker.setOpacity(1);
    marker.setLatLng(e.latlng);
    lat_lng = marker.getLatLng();
    $('upload_latitude').value = lat_lng.lat.toFixed(5);
    $('upload_longitude').value = lat_lng.lng.toFixed(5);
    request_location_by(lat_lng.lat.toFixed(5), lat_lng.lng.toFixed(5));
    zoom_level = map.getZoom();
  });

});

var timeout = null;

function request_location_with(name) {
  if (timeout) {
    clearTimeout(timeout);
  }
  timeout = setTimeout(function() {
    $('upload-location-search-result').update();
    if ( name && name.length > 2 ) {
      // https://open.mapquestapi.com
      // http://prometheus-app.uni-koeln.de/redmine/projects/prometheus/wiki/API_Accounts
      new Ajax.Request('https://open.mapquestapi.com/nominatim/v1/search.php?key=6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ&format=json&q=' + name, {
        method: 'get',
        onSuccess: function(response) {
          var json = response.responseText.evalJSON();
          if (json.length > 0) {
            json.each(function(result) {
              $('upload-location-search-result').insert('<li onmouseover="show_location(' + result.lat + ', ' + result.lon + ');" onclick="select_location(' + result.lat + ', ' + result.lon + ', \'' + result.display_name + '\');">' + result.display_name + '</li>');
            });
            $('upload-location-search-result').show();
          } else {
            $('upload-location-search-result').hide();
          }
        },
        onFailure: function() {
          console.log('Something went wrong...');
          $('upload-location-search-result').hide();
        }
        });
    }
  }, 500);
}

function request_location_by(lat, lon) {
  // https://open.mapquestapi.com
  // http://prometheus-app.uni-koeln.de/redmine/projects/prometheus/wiki/API_Accounts
  new Ajax.Request('https://open.mapquestapi.com/nominatim/v1/reverse.php?key=6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ&format=json&lat=' + lat + '&lon=' + lon, {
      method: 'get',
      onSuccess: function(response) {
        var result = response.responseText.evalJSON();
        $('upload-location-search-result').update();
        $('upload-location-search-result').insert('<li onmouseover="show_location(' + result.lat + ', ' + result.lon + ');" onclick="select_location(' + result.lat + ', ' + result.lon + ', \'' + result.display_name + '\');">' + result.display_name + '</li>');
        $('upload-location-search-result').show();
      },
      onFailure: function() {
        console.log('Something went wrong...');
        $('upload-location-search-result').hide();
      }
      });
}

function show_location(lat, lon) {
  marker.setOpacity(1);
  marker.setLatLng([lat, lon]);
  map.setView([lat, lon], zoom_level);
  $('upload_latitude').value = lat.toFixed(5);
  $('upload_longitude').value = lon.toFixed(5);
}

function select_location(lat, lon, display_name) {
  $('upload_location').value = display_name;
  $('upload_latitude').value = lat.toFixed(5);
  $('upload_longitude').value = lon.toFixed(5);
  $('upload-location-search-result').hide();
}
