Pandora.Behaviour.register({
  'h3.api-method': {
    click: function(e) {
      Pandora.Utils.toggle_details(this, e);
    }
  }
});

Pandora.Utils.toggle_details = function(element, e) {
  var class_name = '.api-details';

  var details = element.next(class_name)
  if (details) {
    if (e && Pandora.Utils.modifier_key(e)) {
      $$(class_name).invoke(details.visible() ? 'hide' : 'show')
    }
    else {
      details.toggle();
    }
  }
}

Pandora.Utils.wrap('reveal_anchor', function(proceed, anchor) {
  var element = $(anchor);
  if (element) {
    Pandora.Utils.toggle_details(element);
    element.scrollTo();
  }
  else {
    proceed(anchor);
  }
});
