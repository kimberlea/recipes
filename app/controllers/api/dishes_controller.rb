class Api::DishesController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Dish",
    endpoints: {
      favorite: :favorite_as_action!,
      import_from_url: {model_class_method: :import_from_url_as_action!},
      search: {model_class_method: :search_as_action!}
    }

end
