Pandora.Behaviour.register({
  '#issuer': {
    change: function(e) {
      var i = $('include_ips');
      if (i && !this.value.blank()) {
        i.checked = false;
      }
    }
  }
});
