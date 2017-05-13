class UserReactionsController < ApplicationController

  before_action :load_user_reaction

  def index
    @user_reaction = UserReaction.all
  end

  def save
    @user_reaction ||= UserReaction.new
    @user_reaction.user_id = current_user.id
    @user_reaction.recipe_id = params[:recipe_id] if params[:recipe_id]
    @user_reaction.is_favorite = params[:is_favorite] == "true" if params[:is_favorite].present?

    saved = @user_reaction.save
    # update recipe
    if (recipe = @user_reaction.recipe)
      recipe.update_meta
    end
    res = { success: saved, data: @user_reaction.to_api}
    render_result(res)
  end

  def delete
    if @user_reaction.nil?
      res = {success: false, error: "You do not like this recipe."}
    else
      @user_reaction.destroy
      res = {success: true, data: @user_reaction.to_api}
    end
    render_result(res)
  end



  private

  def load_user_reaction
    if params[:id].present?
      @user_reaction = UserReaction.find(params[:id])
    end
  end
end
