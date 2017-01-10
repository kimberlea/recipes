
function saveRecipe() {
  var title = $('input[name=title]').val();
  var serving_size = $('input[name=serving_size]').val();
  var description = $('textarea[name=description]').val();
  var ingredients = $('textarea[name=ingredients]').val();
  var directions = $('textarea[name=directions]').val();
  var prep_time = $('input[name=prep_time]').val();
  var tags_str = $('textarea[name=tags]').val();
  var tags = tags_str.split(",");
  var image = $('input[name=image]')[0].files[0];
  var id = getRecipeId();

  data = {
    id: id,
    title: title,
    serving_size: serving_size,
    description: description,
    ingredients: ingredients,
    directions: directions,
    prep_time: prep_time,
    tags: JSON.stringify(tags),
  };

  if (image != null) {
    data['image'] = image;
  }

  apiRequest({
    url: "/recipe",
    method: "POST",
    data: data,
    hasFile: true,
    success: function(resp) {
      navigateTo(resp.data.view_path);
    },
    error: function(resp) {
      alert(resp.error);
    }
  });
}

function promptDeleteRecipe() {
  $.confirm({
    title: "Delete this recipe?",
    content: "Are you sure you want to delete this recipe?",
    buttons: {
      confirm: function() {
        deleteRecipe();
      },
      cancel: function() {}
    }
  });
}

function deleteRecipe() {
  id = getRecipeId();
  apiRequest({
    url: "/recipe",
    method: "DELETE",
    data: {id: id},
    success: function (resp) {
      navigateTo("/recipes");
    }
  });
}

function getRecipeId() {
  return $('input[name=id]').val();
}
