class Api::AccountController < ApiController

  def save
    user = current_user
    res = user.update_as_action!(params_with_actor)
    render_result(res)
  end

end
