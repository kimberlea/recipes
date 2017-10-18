class Api::FeaturesController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Feature",
    endpoints: {
      cancel: :cancel_as_action!
    }

end
