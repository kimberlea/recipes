function logIn() {
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
      navigateTo("/recipes");
    },
    error: function(resp) {
      $.alert(resp.error);
    }
  })
}
