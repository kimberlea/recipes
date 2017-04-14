class ApplicationController < ActionController::Base
  include QuickAuth::Authentication
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_action :setup_vars

  def render_result(res)
    status = res[:success] == true ? 200 : 500
    if res[:success] == false && res[:error].blank? && res[:data][:errors].present?
      res[:error] = res[:data][:errors].first.last.first
    end
    render :json => res, :status => status
  end

  private

  def setup_vars
    @show_header = true
  end

  #def current_user
    #@current_user = User.find(session[:user_id])
  #end
end
