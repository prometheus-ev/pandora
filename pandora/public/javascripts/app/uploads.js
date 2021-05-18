// Pandora.Behaviour.register({
// '#upload_list_form .image img': {
//     mouseover: function(e) {
//       this.zoom(2, 'toggle_uploads_zoom');
//     },
//     mouseout: function(e) {
//       this.unzoom('toggle_uploads_zoom');
//     },
//     click: function(e) {
//       this.unzoom('toggle_uploads_zoom');
//     }
//   }
// });

var inputs = new Hash({});
var zeroIndexSelected = true;

function check_input() {
  if (!$('upload_rights_reproduction_other_photographer').checked) {
    // REWRITE: the empty value doesn't prevent the input from overruling the
    // radio button's value
    // $('upload_rights_reproduction').value="";
    $('upload_rights_reproduction').disabled = true;
  }
  if (!$('upload_rights_work_other_holder_of_rights').checked) {
    // REWRITE: the empty value doesn't prevent the input from overruling the
    // radio button's value
    // $('upload_rights_reproduction').value="";
    // $('upload_rights_work').value="";
    $('upload_rights_work').disabled = true;
  }
  if ($('upload_license').options[$('upload_license').selectedIndex].value == "Other") {
    $('upload_license').options[$('upload_license').selectedIndex].value=$('upload_license_text_field').value;
  }
  if (!$('upload_license').options[$('upload_license').selectedIndex].value == "Other") {
    $('upload_license_text_field').value="";
  }
  return true;
}

function toggle_other_license_text_field() {
  if ($('upload_license').options[$('upload_license').selectedIndex].value == "Other") {
    $('license_table_row').show();
    $('upload_license_text_field').focus();
  } else {
    $('license_table_row').hide();
  }
}

function update_image_and_metadata() {
  update_image();
  update_metadata_select();
}

function update_image() {
  if ($('upload_parent_id').selectedIndex == "") {
    $('parent-image').hide();
    $('parent-image').src = "";
  } else {
    var id = $('upload_parent_id').value;
    // REWRITE: we need the locale here
    // new Ajax.Request(Pandora.root_url + '/upload/record_image_url', {
    new Ajax.Request(Pandora.root_url + Upgrade.current_locale() + '/uploads/' + id + '/record_image_url', {
      method: 'get',
      onSuccess: function(response) {
        $('parent-image').src = response.responseText;
      },
      onFailure: function() {
        console.log('Something went wrong...');
      }
    });
    $('parent-image').show();
  }
}

function checkbox_clicked(id) {
  if ($('reuse_latest_metadata').checked) {
    backup_metadata();
    get_metadata(id);
  } else {
    restore_metadata();
  }
}

function update_metadata_select(id) {
  if (typeof(id) === 'undefined') {
    id = $('upload_parent_id').value;
  }
  if ($('upload_parent_id').selectedIndex == "") {
    restore_metadata();
  } else {
    backup_metadata();
    get_metadata(id);
    if ($('reuse_latest_metadata') && $('reuse_latest_metadata').checked) {
      $('reuse_latest_metadata').checked = false;
    }
  }
}

function backup_metadata() {
  if (zeroIndexSelected === true) {
    // reset hash
    inputs = new Hash({});
    $$('input','textarea','select').each(function(input) {
      if (input.type === 'text') {
        inputs.set(input.id, input.value);
      } else if (input.tagName === 'TEXTAREA') {
        inputs.set(input.id, input.innerHTML);
      } else if (input.tagName === 'SELECT') {
        inputs.set(input.id, input.options[input.selectedIndex].value);
      } else if (input.type === 'radio' && input.checked) {
        inputs.set(input.id, input.value);
      }
      if (!$('upload_rights_reproduction_other_photographer').checked) {
        inputs.set('upload_rights_reproduction', "");
      }
      if (!$('upload_rights_work_other_holder_of_rights').checked) {
        inputs.set('upload_rights_work', "");
      }
      if ($('upload_license').options[$('upload_license').selectedIndex].value != "Other") {
        inputs.set('upload_license_text_field', "");
      }
    });
    zeroIndexSelected = false;
  }
}

function restore_metadata() {
  zeroIndexSelected = true;
  $$('#content input','#content textarea','#content select').each(function(input) {
    if (input.type === 'text') {
      $(input.id).value = inputs.get(input.id);
    } else if (input.tagName === 'TEXTAREA') {
      $(input.id).innerHTML = inputs.get(input.id);
    } else if (input.tagName === 'SELECT') {
      $(input.id).value = inputs.get(input.id);
      toggle_other_license_text_field();
    } else if (input.type === 'radio') {
      $(input.id).checked = ($(input.id).value == inputs.get(input.id));
    }
  });
}

function get_metadata(id) {
  new Ajax.Request(Pandora.root_url + '/api/json/upload/' + id, {
    method: 'get',
      onSuccess: function(response) {
        var json = response.responseText.evalJSON();

        $$('#content input','#content textarea','#content select').each(function(input) {
          if (input.type === 'text' && !(input.id === 'upload_rights_reproduction' || input.id === 'upload_rights_work')) {
            if (input.id != 'upload_title') {
              $(input.id).value=json[input.id.substr(7)];
            }
          } else if (input.type === 'text' && (input.id === 'upload_rights_reproduction' || input.id === 'upload_rights_work')) {
            checked = false;
            buttons = document.getElementsByName('upload[' + input.id.substr(7) + ']');
            for (var i = 0; i < buttons.length; i++) {
              if (buttons[i].checked) {
                checked = true;
              }
            }
            if (!checked) {
              if (input.id === 'upload_rights_reproduction') {
                $(input.id + '_other_photographer').checked = true;
              } else if (input.id === 'upload_rights_work') {
                $(input.id + '_other_holder_of_rights').checked = true;
              }
              $(input.id).value=json[input.id.substr(7)];
            } else {
              $(input.id).value="";
            }
          } else if (input.tagName === 'TEXTAREA') {
            console.log(json, input.id)
            $(input.id).innerHTML = json[input.id.substr(7)];
          } else if (input.tagName === 'SELECT') {
            $(input.id).value = json[input.id.substr(7)];
            toggle_other_license_text_field();
          } else if (input.type === 'radio') {
            $(input.id).checked = ($(input.id).value == json[input.name.substring(0, input.name.length - 1).substr(7)]);
          }
        });
      },
      onFailure: function() {
        console.log('Something went wrong...');
      }
  });
}

Pandora.Utils.list_toggle('upload', 'upload_list_form');
