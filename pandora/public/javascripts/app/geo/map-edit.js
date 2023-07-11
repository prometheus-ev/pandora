var map = null;
var marker = null;

document.observe("dom:loaded", function() {
  // https://developer.mapquest.com/documentation/mapquest-js/v1.3/
  L.mapquest.key = 'FILL-ME-IN';

  if (L.mapquest.key == 'FILL-ME-IN') return

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
  var ul = document.querySelector('#upload-location-search-result')
  timeout = setTimeout(function() {
    ul.innerHTML = ''

    if ( name && name.length > 2 ) {
      // http://prometheus-app.uni-koeln.de/redmine/projects/prometheus/wiki/API_Accounts
      // https://developer.mapquest.com/documentation/geocoding-api/address/get/
      var url =
        'https://www.mapquestapi.com/geocoding/v1/address?' +
        'key=6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ&' +
        'location=' + name

      new Ajax.Request(url, {
        method: 'get',
        onSuccess: function(response) {
          var json = response.responseText.evalJSON();
          var locations = json.results[0].locations

          if (locations.length == 0) {
            ul.style.display = 'none'
            return
          }

          locations.each(location => {
            var li = locationToListItem(location)
            ul.append(li)
          });

          ul.style.display = 'block'
        },
        onFailure: function() {
          console.log('Something went wrong...');
          ul.style.display = 'none'
        }
        });
    }
  }, 500);
}

function request_location_by(lat, lng) {
  // http://prometheus-app.uni-koeln.de/redmine/projects/prometheus/wiki/API_Accounts
  // https://developer.mapquest.com/documentation/geocoding-api/reverse/get/
  var url =
    'https://www.mapquestapi.com/geocoding/v1/reverse?' +
    'key=6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ&' +
    'location=' + lat + ',' + lng

  new Ajax.Request(url, {
    method: 'get',
    onSuccess: function(response) {
      var json = response.responseText.evalJSON()
      var locations = json.results[0].locations

      var ul = document.querySelector('#upload-location-search-result')
      ul.innerHTML = ''
      locations.each(location => {
        var li = locationToListItem(location)
        ul.append(li)
      })

      ul.style.display = 'block'
    },
    onFailure: function() {
      console.log('Something went wrong...');
      ul.style.display = 'none'
    }
  });
}

function locationToListItem(location) {
  var scope =
    Object.keys(location).
    filter(k => k.match(/^adminArea\d$/)).
    sort().
    reverse().
    filter(k => !!location[k]).
    map(k => location[k])
  var name = [...new Set(scope)].join(', ')

  var li = document.createElement('li')
  li.textContent = name
  var lat = location.latLng.lat
  var lng = location.latLng.lng
  li.addEventListener('mouseover', event => show_location(lat, lng))
  li.addEventListener('click', event => select_location(lat, lng, name))

  return li
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
