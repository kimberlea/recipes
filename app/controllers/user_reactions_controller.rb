class UserReactionsController < ApplicationController

  before_action :load_user_reaction

  def index
    @user_reaction = UserReaction.all
  end

  private

  def load_user_reaction
    if params[:id].present?
      @user_reaction = UserReaction.find(params[:id])
    end
  end
end
