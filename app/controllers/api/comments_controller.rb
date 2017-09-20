class Api::CommentsController < ApiController
  include QuickScript::ModelEndpoints

  configure_model_endpoints_for "Comment"

  def prepare_model(model)
    models = model.is_a?(Array) ? model : [model]
    enhances = request_scope.enhances
    if enhances.include?("dish_reaction")
      Comment.enhance_dish_reaction(models, actor: current_user)
    end
  end

end
