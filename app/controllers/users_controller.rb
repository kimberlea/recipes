class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @filter = params[:filter]
    

    if @filter == "favorite"
      @recipes = Recipe.joins(:user_reactions).where("user_reactions.is_favorite = true and user_reactions.user_id = ?", @user.id)
    else
      @recipes = Recipe.where(creator_id: @user.id)
    end

    if current_user
      @following = self.current_user.following_of(@user) 
    else
      @following = nil
    end
    
  end

  def index
    # load users
    @users = User.all

    # load count for all recipes favorited

  end


end

