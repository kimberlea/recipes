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
      @dishes = Dish.where(creator_id: current_user.id)
    elsif @filter_creator == "friends"
      @dishes = Dish.is_public.where("creator_id IN (SELECT user_id from followings where followings.follower_id = ?)", current_user.id)
    else
      @dishes = Dish.is_public
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
    @dishes = Dish.is_public.limit(8).order("created_at desc")
  
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
    render "dishes/edit"
  end

  def share_your_dish_modal
    render layout: nil
  end

  def save
    @dish ||= Dish.new
    new_record = @dish.new_record?
    if new_record
      @dish.creator = self.current_user
    end
    @dish.title = params[:title] if params.key?(:title)
    @dish.serving_size = params[:serving_size] if params.key?(:serving_size)
    @dish.description = params[:description] if params.key?(:description)
    @dish.ingredients = params[:ingredients] if params.key?(:ingredients)
    @dish.directions = params[:directions] if params.key?(:directions)
    @dish.purchase_info = params[:purchase_info] if params.key?(:purchase_info)
    @dish.prep_time_mins = params[:prep_time_mins].to_i if params.key?(:prep_time_mins)
    @dish.is_purchasable = (params[:is_purchasable]=="true") if params.key?(:is_purchasable)
    @dish.is_private = (params[:is_private]=="true") if params.key?(:is_private)
    @dish.is_recipe_private = (params[:is_recipe_private]=="true") if params.key?(:is_recipe_private)
    @dish.is_recipe_given = (params[:is_recipe_given]=="true") if params.key?(:is_recipe_given)
    if params.key?(:tags)
      tags = JSON.parse(params[:tags])
      tags = tags.collect {|tag| tag.strip.downcase}
      @dish.tags = tags
    end
    if params.key?(:image)
      @dish.image = params[:image]
    end
    saved = @dish.save
    if saved && new_record
      AppEvent.publish("dish.created", current_user, {dish: @dish})
    end
    res = {success: saved, data: @dish.to_api}
    render_result(res)
  end

  def delete
    if @dish.nil?
      res = {success: false, error: "Dish could not be found."}
    else
      @dish.destroy
      res = {success: true, data: @dish.to_api}
    end
    render_result(res)
  end

  def favorite
    @reaction = current_user.reaction_to(@dish, true)
    @reaction.is_favorite = true
    saved = @reaction.save
    if saved
      AppEvent.publish("dish.favorited", current_user, dish: @reaction.dish)
    end
    render_result({success: true, data: @reaction.to_api})
  end

  private

  def load_dish
    if params[:id].present?
      @dish = Dish.find(params[:id])
    end
  end

end
