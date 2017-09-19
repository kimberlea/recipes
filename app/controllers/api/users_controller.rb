class Api::UsersController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "User"
end
