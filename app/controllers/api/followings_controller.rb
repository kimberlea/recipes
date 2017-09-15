class Api::FollowingsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Following"

end

