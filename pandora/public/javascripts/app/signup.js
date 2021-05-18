console.log('loading');

Pandora.Behaviour.register({
  '#forgot_password': {
    click: function(e) {
      var l = this.up('form').login;
      if (l && !l.value.blank()) {
        this.href = this.href.append_query({ login: l.value });
      }
    }
  },
  '#password': {
    'dom:loaded': function(e) {
      var l = $('login');
      if (l && !l.value.blank()) {
        this.focus();
      }
    }
  },
  '#toggle_terms_of_use': {
    click: function(e) {
      var t = $('terms_of_use');
      if (t) {
        t.toggle();
        e.stop();

        if (t.visible()) {
          t.scrollTo();
        }
      }
    }
  },
  'body.signup-controller.license_form-action #user_institution': {
    change: function(e) {
      var c = $('user_mode_institution');
      if (c) {
        c.click();
      }
    }
  },
  'body.signup-controller.license_form-action #invoice_address': {
    'dom:loaded': function(e) {
      var c = $('user_mode_invoice');
      if (c && c.checked) {
        this.show();
      }
    }
  },
  'body.signup-controller.license_form-action input[name="user[mode]"]': {
    click: function(e) {
      var a = $('invoice_address');
      if (a) {
        if (this.id === 'user_mode_invoice') {
          a.show();
        }
        else {
          a.hide();
        }
      }
    }
  },
  'body.signup-controller.signup_form-action input[name="type"]': {
    'dom:loaded': function(e) {
      // default type is now set to guest
      //$('user_research_interest').removeClassName("mandatory");
      $('user_research_interest').addClassName("mandatory");
    },
    change: function(e) {
      if (e['target']['value'] == 'institution') {
        $('user_research_interest').removeClassName("mandatory");
      }
      else {
        $('user_research_interest').addClassName("mandatory");
      };
    }
  }
});
