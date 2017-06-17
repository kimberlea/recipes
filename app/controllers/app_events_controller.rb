class AppEventsController < ApplicationController

  def activity
    if current_user.nil?
      redirect_to "/"
      return
    end
    filter = params[:filter]
    if filter == "favorites"
      page_info[:title] = "Recent Favorites"
      @events = AppEvent.includes(["recipe", "actor", "user", "comment"]).relevant_for_user(current_user).with_any_action("recipe.favorited").not_with_actor(current_user).order("created_at DESC").limit(100)
    else
      page_info[:title] = "Recent Activity"
      @events = AppEvent.includes(["recipe", "actor", "user", "comment"]).relevant_for_user(current_user).order("created_at DESC").limit(100)
    end
  end

end
