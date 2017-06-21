class CommentsController < ApplicationController 
    
    def save 
        @comment ||= Comment.new
        new_record = @comment.new_record?
        @comment.dish_id = params[:dish_id] if params[:dish_id]
        @comment.body = params[:body] if params[:body]
        @comment.user_id = current_user.id

        saved = @comment.save
        if saved && new_record
          AppEvent.publish("dish.commented", current_user, {comment: @comment, dish: @comment.dish})
        end
        res = { success: saved, data: @comment.to_api}
        render_result(res)    
    end
end
