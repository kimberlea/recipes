class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  def render_result(res)
    status = res[:success] == true ? 200 : 500
    if res[:success] == false && res[:error].blank? && res[:data][:errors].present?
      res[:error] = res[:data][:errors].first.last.first
    end
    render :json => res, :status => status
  end
end
