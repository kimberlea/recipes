class Api::InvoicesController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Invoice"

end

