function saveAccount(opts={}) {
  var first_name = $('input[name=first_name]').val();
  var last_name = $('input[name=last_name]').val();
  var email = $('input[name=email]').val();
  var password = $('input[name=password]').val();

  data = {
    first_name: first_name,
    last_name: last_name,
    email: email,
    password: password,
  };

  apiRequest({
    url: "/register",
    method: "POST",
    data: data,
    success: function(resp) {
      setCurrentUser(resp.data);
      //console.log("Got here 1");
      if (opts.redirect) {
         //console.log("Got here 2");
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

