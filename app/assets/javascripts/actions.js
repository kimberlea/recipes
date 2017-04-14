function followUser(user_id, update_parts) {
  if (!isSignedIn()) {
    showModalFromURL("sign_up", "/modal/sign_up");
    return;
  }
 
  data = {
    user_id: user_id,
  }


  apiRequest({
    url: "/following",
    method: "POST",
    data: data,
    success: function(resp) {
      updatePage(update_parts);
    },
    error: function(resp) {
      $.alert(resp.error);
    }
  })
}

function deleteFollowing(id, update_parts) {

  data = {
    id: id
  }


  apiRequest({
    url: "/following",
    method: "DELETE",
    data: data,
    success: function (resp) {
      updatePage(update_parts);
    }
  });

}

function favoriteRecipe(recipe_id) {
   if (!isSignedIn()) {
    showModalFromURL("sign_up", "/modal/sign_up");
    return
   }


  data = {
    id: recipe_id
  }

  apiRequest({
    url: "/recipe/favorite",
    method: "POST",
    data: data,
    success: function(resp) {
      updatePage([".recipe-meta"]);
    }
  });

}

function unfavoriteRecipe(id) {

  data = {
    id: id,
    is_favorite: false
  }

  apiRequest({
    url: "/user_reaction",
    method: "POST",
    data: data,
    success: function(resp) {
      updatePage([".recipe-meta"]);
    }
  });
}
