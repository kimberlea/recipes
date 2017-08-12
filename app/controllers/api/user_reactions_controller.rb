class Api::UserReactionsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "UserReaction"

end
