class Api::LocationsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Location"

end
