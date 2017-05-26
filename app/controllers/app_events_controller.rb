class AppEventsController < ApplicationController

  def activity
    if current_user.nil?
      redirect_to "/"
      return
    end
    @events = AppEvent.includes(["recipe", "actor", "user", "comment"]).relevant_for_user(current_user).order("created_at DESC").limit(100)
  end

end
