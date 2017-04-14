class CommentsController < ApplicationController 
    
    def save 
        @comment ||= Comment.new
        @comment.recipe_id = params[:recipe_id] if params[:recipe_id]
        @comment.body = params[:body] if params[:body]
        @comment.user_id = current_user.id

        saved = @comment.save
        res = { success: saved, data: @comment.to_api}
        render_result(res)    
    end
end
