class AccountController < ApplicationController

  # views/pages

  def sign_up
    @show_header = false
    @body_style = "bg-wood"
  end

  def sign_in
    @show_header = false
    @body_style = "bg-wood"
  end

  def edit
    if current_user.nil?
      redirect_to "/sign_in"
    end
    @user = current_user

    @js_data[:user] = @user.to_api
  end

  def logout
    reset_session
    redirect_to "/"
  end

end
