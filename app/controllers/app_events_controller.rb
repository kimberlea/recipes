class AppEventsController < ApplicationController

  def activity
    filter = params[:filter]
    if filter == "favorites"
      page_info[:title] = "Recent Favorites"
      @events = AppEvent.includes(["dish", "actor", "user", "comment"]).with_any_action("dish.favorited").order("created_at DESC").limit(100)
    else
      page_info[:title] = "Recent Activity"
      @events = AppEvent.includes(["dish", "actor", "user", "comment"]).order("created_at DESC").limit(100)
    end
    if current_user
      @events = @events.relevant_for_user(current_user).not_with_actor(current_user)
    end
  end

end
