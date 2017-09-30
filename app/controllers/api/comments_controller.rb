class Api::CommentsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Comment"

  def prepare_model(model)
    models = model.is_a?(Array) ? model : [model]
    incls = request_context.includes
    if incls.include?("dish_reaction")
      Comment.include_dish_reaction(models, actor: current_user)
    end
  end

end
