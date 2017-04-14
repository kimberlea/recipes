class RecipesController < ApplicationController

  before_action :load_recipe

  def index
    @body_style = "bg-white"
    @q = params[:q]
    @filter_favorite = params[:favorite] == "true"
    @creator_filter = params[:creator] || "all"

    if @creator_filter == "me"
      @recipes = Recipe.where(creator_id: current_user.id)
    elsif @creator_filter == "friends"
      @recipes = Recipe.is_public.where("creator_id IN (SELECT user_id from followings where followings.follower_id = ?)", current_user.id)
    else
      @recipes = Recipe.is_public
    end

    if @filter_favorite && current_user
      @recipes = @recipes.joins(:user_reactions).where("user_reactions.is_favorite = true and user_reactions.user_id = ?", current_user.id)
    end

    if @q.present?
      @recipes = @recipes.where("title ILIKE ?", "%#{@q}%")
    end

    @recipes = @recipes.order(:title)
  end

  def show
    @body_style = "bg-white"

    @recipe = Recipe.find(params[:id])
    @creator = @recipe.creator
    if self.current_user
      @following = self.current_user.following_of(@creator)
      @user_reaction = self.current_user.reaction_to(@recipe)
    else
      @following = nil
      @user_reaction = nil
    end
    # load comments
    @comments = Comment.where(recipe_id: @recipe.id).order("created_at desc")

    # load 5 most recent recipes
    @recipes = Recipe.is_public.limit(5).order("created_at desc")
  
   
  end

  def create
    @body_style = "bg-image"
    @title = "Create New Recipe."
    @recipe = Recipe.new
    render "recipes/edit"
  end

  def edit
    @body_style = "bg-image"
    @title = "Edit This Recipe."
    render "recipes/edit"
  end

  def save
    @recipe ||= Recipe.new
    @recipe.title = params[:title] if params.key?(:title)
    @recipe.serving_size = params[:serving_size] if params.key?(:serving_size)
    @recipe.description = params[:description] if params.key?(:description)
    @recipe.ingredients = params[:ingredients] if params.key?(:ingredients)
    @recipe.directions = params[:directions] if params.key?(:directions)
    @recipe.prep_time_mins = params[:prep_time_mins] if params.key?(:prep_time_mins)
    @recipe.is_private = (params[:is_private]=="true") if params.key?(:is_private)
    @recipe.creator = self.current_user
    if params.key?(:tags)
      tags = JSON.parse(params[:tags])
      tags = tags.collect {|tag| tag.strip.downcase}
      @recipe.tags = tags
    end
    if params.key?(:image)
      @recipe.image = params[:image]
    end
    saved = @recipe.save
    res = {success: saved, data: @recipe.to_api}
    render_result(res)
  end

  def delete
    if @recipe.nil?
      res = {success: false, error: "Recipe could not be found."}
    else
      @recipe.destroy
      res = {success: true, data: @recipe.to_api}
    end
    render_result(res)
  end

  def favorite
    @reaction = current_user.reaction_to(@recipe, true)
    @reaction.is_favorite = true
    @reaction.save
    render_result({success: true, data: @reaction.to_api})
  end

  private

  def load_recipe
    if params[:id].present?
      @recipe = Recipe.find(params[:id])
    end
  end

end
