class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    
    if current_user.present?
      @user.following = self.current_user.following_of(@user) 
    end

    @js_data[:user] = @user.to_api if @user
    @page_info = {
      title: @user.full_name,
      description: "Check out my dishes on Dishfave.com!",
      url: @user.view_path,
      image: @user.picture_url,
    }
  end

  def index
    # load users
    @users = User.all

    # load count for all dishes favorited

  end


  def following
    show
  end

  def followers
    show
  end

end

