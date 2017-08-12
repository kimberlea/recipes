class Api::DishesController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Dish",
    endpoints: {
      favorite: :favorite_as_action!
    }

end
