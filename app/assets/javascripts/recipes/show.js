function followUser(user_id) {

  data = {
    user_id: user_id,
  }


  apiRequest({
    url: "/following",
    method: "POST",
    data: data,
    success: function(resp) {
      updatePage([".recipe-meta"]);
    },
    error: function(resp) {
      $.alert(resp.error);
    }
  })
}

function deleteFollowing(id) {

  data = {
    id: id
  }


  apiRequest({
    url: "/following",
    method: "DELETE",
    data: data,
    success: function (resp) {
      updatePage([".recipe-meta"]);
    }
  });

}

function favoriteRecipe(recipe_id) {

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
