class Api::CommentsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Comment"

end
