class FollowingsController < ApplicationController

  before_action :load_following

  def save
    @following ||= Following.new
    @following.follower_id = current_user.id
    @following.user_id = params[:user_id]

    saved = @following.save
    res = {success: saved, data: @following.to_api}
    render_result(res)
  end

  def delete
    if @following.nil?
      res = {success: false, error: "You are not following this user."}
    else
      @following.destroy
      res = {success: true, data: @following.to_api}
    end
    render_result(res)
  end

  private

  def load_following
    if params[:id].present?
      @following = Following.find(params[:id])
    end
  end
end
