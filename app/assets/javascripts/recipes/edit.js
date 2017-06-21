
function saveRecipe() {
  if (!isSignedIn()) {
    showModalFromURL("sign_up", "/modal/sign_up");
    return
  }
  var title = $('input[name=title]').val();
  var serving_size = $('input[name=serving_size]').val();
  var description = $('textarea[name=description]').val();
  var ingredients = $('textarea[name=ingredients]').val();
  var directions = $('textarea[name=directions]').val();
  var purchase_info = $('textarea[name=purchase_info]').val();
  var prep_time_hours = parseInt($('input[name=prep_time_hours]').val()) || 0;
  var prep_time_minutes = parseInt($('input[name=prep_time_minutes]').val()) || 0;
  var tags_str = $('textarea[name=tags]').val();
  var tags = tags_str.split(",");
  var image = $('input[name=image]')[0].files[0];
  var is_private = $('input[name=is_private]').is(':checked');
  var is_recipe_private = $('input[name=is_recipe_private]').is(':checked');
  var id = getRecipeId();

  var prep_time_mins = prep_time_hours * 60 + prep_time_minutes;

  data = {
    id: id,
    title: title,
    serving_size: serving_size,
    description: description,
    ingredients: ingredients,
    directions: directions, 
    purchase_info: purchase_info, 
    prep_time_mins: prep_time_mins,
    is_private: is_private,
    is_recipe_private: is_recipe_private,
    tags: JSON.stringify(tags),
 
  };

  if (image != null) {
    data['image'] = image;
  }

  apiRequest({
    url: "/dish",
    method: "POST",
    data: data,
    hasFile: true,
    success: function(resp) {
      navigateTo(resp.data.view_path);
    },
    error: function(resp) {
      $.alert(resp.error);
    }
  });
}

function promptDeleteRecipe() {
  $.confirm({
    title: "Delete this dish?",
    content: "Are you sure you want to delete this dish?",
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
    url: "/dish",
    method: "DELETE",
    data: {id: id},
    success: function (resp) {
      navigateTo("/dishes");
    }
  });
}

function getRecipeId() {
  return $('input[name=id]').val();
}

function toggleHowToMakeVisible(el) {
  var do_hide = $(el).is(":checked");
  var $htm = $('.howtomake-fields');
  if (do_hide) {
    $htm.hide();
  } else { 
    $htm.show();
  }
}
