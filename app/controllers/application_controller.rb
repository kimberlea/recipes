class ApplicationController < ActionController::Base
  include QuickAuth::Authentication
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  before_action :setup_vars
  helper_method :page_title, :page_info, :is_me?

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

  def page_title
    if page_info[:title].present?
      "#{page_info[:title]} on Dishfave"
    else
      "Dishfave"
    end
  end

  def page_info
    return @page_info ||= {}
  end

  def is_me?(user)
    return false if (current_user.nil? || user.nil?)
    return current_user.id == user.id
  end

  #def current_user
    #@current_user = User.find(session[:user_id])
  #end
end
