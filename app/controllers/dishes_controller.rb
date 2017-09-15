class DishesController < ApplicationController

  before_action :load_dish

  def index
    @body_style = "bg-white"
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
      @creator.following = @following
      @user_reaction = self.current_user.reaction_to(@dish)
      @dish.user_reaction = @user_reaction
    else
      @following = nil
      @user_reaction = nil
    end
    # load comments
    #@comments = Comment.where(dish_id: @dish.id).order("created_at desc")

    # load 5 most recent dish
    #@dishes = Dish.is_visible_by(current_user).limit(8).order("created_at desc")

    @dish.api_request_scope = QuickScript::SmartScope.new(actor: current_user, enhances: ["description_html", "ingredients_html", "directions_html", "purchase_info_html"])

    @js_data[:dish] = @dish.to_api if @dish
  
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
