class Api::AccountController < ApiController

  def save
    user = current_user
    res = user.update_as_action!(params_with_actor)
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

  def register
    @user = User.new
    res = @user.update_as_action!(params)
    if res[:success] == true
      self.current_user = @user
    end
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

  def update_payment_method
    user = current_user
    res = user.update_payment_method_as_action!(params_with_context)
    render_result(res)
  end
  def delete_payment_method
    user = current_user
    res = user.delete_payment_method_as_action!(params_with_context)
    render_result(res)
  end

end
