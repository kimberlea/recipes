function logIn(opts={}) {
  var email = $('input[name=email]').val();
  var password = $('input[name=password]').val();

  data = {
    email: email,
    password: password,
  }


  apiRequest({
    url: "/login",
    method: "POST",
    data: data,
    success: function(resp) {
      setCurrentUser(resp.data);
      if (opts.redirect) {
        navigateTo(opts.redirect);
      } else if (opts.callback) {
        opts.callback(resp);
      }
    },
    error: function(resp) {
      $.alert(resp.error);
    }
  })
}

