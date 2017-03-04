class AccountController < ApplicationController

  # views/pages

  def sign_up
    @body_style = "bg-wood"
  end

  def sign_in
    @body_style = "bg-wood"
  end

  def profile
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
    self.current_user = nil
  end

  def save
  end




end
