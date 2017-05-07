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

    @page_info = {
      title: @user.full_name,
      description: "Check out my recipes on Dishfave.com!",
      url: @user.view_path,
      image: @user.picture_url,
    }
   
    
  end

  def index
    # load users
    @users = User.all

    # load count for all recipes favorited

  end


  def following
    #load followings
    @user = User.find(params[:id])

    @followings = Following.where(follower_id: @user.id)
    @users = @followings.collect {|f| f.user}
    
   
  end

  def followers
    #load followers
     
    @user = User.find(params[:id])

    #followings where :user_id = params[:id]

    @followings = Following.where(user_id: @user.id)
    @users = @followings.collect {|f| f.follower}
    
  end

end

