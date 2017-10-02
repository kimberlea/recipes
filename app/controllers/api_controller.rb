class ApiController < ApplicationController
  include QuickScript::Interaction

  rescue_from StandardError do |e|
    if Rails.env.test?
      raise e
    end
    Rails.logger.error "\n#{e.message}"
    Rails.logger.error e.backtrace.join("\n\t")
    render :json => {success: false, data: nil, meta: 500, error: "An error occurred processing your request. The Dishfave team will be notified."}, :status => 500
  end

  rescue_from Pundit::NotAuthorizedError do |e|
    render :json => {success: false, error: e.message, error_type: "NotAuthorizedError"}, :status => 403
  end
  
end
