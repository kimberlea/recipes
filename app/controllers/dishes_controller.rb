class DishesController < ApplicationController

  before_action :load_dish

  def index
    @body_style = "bg-white"
    @q = params[:q]
    @filter_favorite = params[:favorite] == "true"
    @filter_creator = params[:creator] || "all"
    @filter_tag = params[:tag] || "all"
    @order = params[:order] || "newest"

    if @filter_creator == "me"
      @dishes = Dish.is_visible_by(current_user).where(creator_id: current_user.id)
    elsif @filter_creator == "friends"
      @dishes = Dish.is_visible_by(current_user).where("creator_id IN (SELECT user_id from followings where followings.follower_id = ?)", current_user.id)
    else
      @dishes = Dish.is_visible_by(current_user)
    end

    if @filter_tag.present? && @filter_tag != "all"
      @dishes = @dishes.with_tag(@filter_tag)
    end

    if @filter_favorite && current_user
      @dishes = @dishes.joins(:user_reactions).where("user_reactions.is_favorite = true and user_reactions.user_id = ?", current_user.id)
    end

    if @q.present?
      @dishes = @dishes.where("search_vector @@ to_tsquery(?)", @q)
    end

    sort = case @order
      when "popular"
        "cached_favorites_count desc"
      when "quickest"
        "prep_time_mins asc"
      else
        "created_at desc"
      end
    @dishes = @dishes.order(sort)
  end

  def show
    @body_style = "bg-white"

    if @dish.is_private && (!signed_in? || @dish.creator.id != current_user.id)
      redirect_to "/"
      return
    end
    @creator = @dish.creator
    if self.current_user
      @following = self.current_user.following_of(@creator)
      @user_reaction = self.current_user.reaction_to(@dish)
    else
      @following = nil
      @user_reaction = nil
    end
    # load comments
    @comments = Comment.where(dish_id: @dish.id).order("created_at desc")

    # load 5 most recent dish
    @dishes = Dish.is_visible_by(current_user).limit(8).order("created_at desc")
  
    @page_info = {
      title: @dish.title,
      description: @dish.description,
      url: @dish.view_path(full: true),
      image: @dish.image.url,
    }
   
  end

  def create
    @body_style = "bg-image"
    @title = "Create New Dish."
    @dish = Dish.new
    render "dishes/edit"
  end

  def edit
    if !(is_me?(@dish.creator) || is_superadmin?)
      redirect_to "/"
      return
    end
    @body_style = "bg-image"
    @title = "Edit This Dish."
    @js_data[:dish] = @dish.to_api
    render "dishes/edit"
  end

  def share_your_dish_modal
    render layout: nil
  end

  private

  def load_dish
    if params[:id].present?
      @dish = Dish.is_visible_by(current_user).find(params[:id])
    end
  end

end
