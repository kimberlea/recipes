class AdminController < ApplicationController

  def view
    if current_user.nil? || !current_user.is_superadmin
      redirect_to "/"
      return
    end
  end

end
