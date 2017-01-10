class RecipesController < ApplicationController

  before_action :load_recipe

  def index
    filter = params[:filter]
    if filter
      @recipes = Recipe.where("title ILIKE ?", "%#{filter}%").order(:title)
    else
      # load all my recipes
      @recipes = Recipe.all.order(:title)
    end
  end


  def show
    @body_style = "bg-white"

    list_id = params[:id]

    @recipe = Recipe.find(list_id)


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
    @recipe.prep_time = params[:prep_time] if params.key?(:prep_time)
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

  private

  def load_recipe
    if params[:id].present?
      @recipe = Recipe.find(params[:id])
    end
  end

end
