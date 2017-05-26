class CommentsController < ApplicationController 
    
    def save 
        @comment ||= Comment.new
        new_record = @comment.new_record?
        @comment.recipe_id = params[:recipe_id] if params[:recipe_id]
        @comment.body = params[:body] if params[:body]
        @comment.user_id = current_user.id

        saved = @comment.save
        if saved && new_record
          AppEvent.publish("recipe.commented", current_user, {comment: @comment, recipe: @comment.recipe})
        end
        res = { success: saved, data: @comment.to_api}
        render_result(res)    
    end
end
