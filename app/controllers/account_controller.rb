class AccountController < ApplicationController

  # views/pages

  def sign_up
    @show_header = false
    @body_style = "bg-wood"
  end

  def sign_up_modal
    render layout: nil
  end

  def sign_in
    @show_header = false
    @body_style = "bg-wood"
  end

  def sign_in_modal
    render layout: nil
  end

  def forgot_password_modal
    render layout: nil
  end

  def profile
    if current_user.nil?
      redirect_to "/sign_in"
    end
  end

  # api calls

  def register
    @user = User.new
    res = @user.update_as_action!(params)
    if res[:success] == true
      self.current_user = @user
    end
    render_result(res)
  end

  def login
    email = params[:email]
    password = params[:password]
    user = User.authenticate(email, password)
    if user
      self.current_user = user
      res = {success: true, data: user}
    else
      res = {success: false, error: "User could not be found."}
    end
    render_result(res)
  end

  def logout
    reset_session
    redirect_to "/"
  end

  def save
    self.current_user.first_name = params[:first_name] if params.key?(:first_name)
    self.current_user.last_name = params[:last_name] if params.key?(:last_name)
    self.current_user.email = params[:email] if params.key?(:email)
    self.current_user.bio = params[:bio] if params.key?(:bio)
    self.current_user.notification_frequency = params[:notification_frequency].to_i if params.key?(:notification_frequency)

    if params.key?(:picture)
      self.current_user.picture = params[:picture]
    end

    if params.key?(:password)
      self.current_user.password = params[:password]
    end

    saved = self.current_user.save
    res = {success: saved, data: self.current_user.to_api}
    render_result(res)
  end

  def update_flags
    flags = JSON.parse(params[:flags])
    flags.each {|f|
      current_user.set_flag!(f)
    }
    render_result(success: true, data: current_user)
  end

  def reset_password
    user = User.find_by_email(params[:email])
    if user.nil?
      render_result(success: false, error: "Could not find this user.")
      return
    end
    user.send_reset_password_email!
    render_result(success: true, data: user)
  end
end

user = User.all
