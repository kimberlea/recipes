class Api::UserReactionsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "UserReaction",
    endpoints: {
      react: {model_class_method: :react_as_action!}
    }

end
