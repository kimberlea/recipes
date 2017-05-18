class AppEvent < ActiveRecord::Base
  include SchemaSync::Model

  field :action, type: String
  
  field :actor_id, type: Integer

  field :recipe_id, type: Integer
  field :comment_id, type: Integer
  field :user_id, type: Integer

  field :meta, type: Hash, default: {}

  belongs_to :recipe
  belongs_to :comment
  belongs_to :user
  belongs_to :actor, class_name: "User"

  timestamps!

  scope :relevant_for_user, lambda {|user|
    where("action IN (?)", ["recipe.created", "recipe.commented", "recipe.favorited", "user.followed"]).where("(actor_id = ?) OR (user_id = ?) OR (recipe_id IN (SELECT id FROM recipes WHERE recipes.creator_id=?)) OR (actor_id IN (SELECT user_id FROM followings WHERE followings.follower_id = ?))", user.id, user.id, user.id, user.id)
  }

  def self.publish(action, actor, models, opts={})
    ev = self.new
    ev.action = action
    ev.actor_id = actor.id
    ev.recipe = models[:recipe]
    ev.comment = models[:comment]
    ev.user = models[:user]
    ev.meta = opts
    ev.save
    return ev
  rescue => ex
    Rails.logger.info ex.message
    return ev
  end

  def title(opts={})
    viewer = opts[:viewer]
    actor_str = actor.full_name
    if viewer == actor
      actor_str = "You"
    end
    action_str = case self.action 
    when "recipe.created"
      "created a new recipe, \"#{recipe.title}\"."
    when "recipe.favorited"
      "favorited the recipe, \"#{recipe.title}\"."
    when "recipe.commented"
      "commented on the recipe, \"#{recipe.title}\"."
    when "user.followed"
      user_str = viewer == user ? "you" : user.full_name
      "started following #{user_str}."
    end
    return "#{actor_str} #{action_str}"
  end

  def body(opts={})
    summ = case self.action
    when "recipe.created", "recipe.favorited"
      recipe.description
    when "recipe.commented"
      comment.body
    when "user.followed"
      user.bio
    end
    return summ
  end

  def subject_image_url
    img = case self.action
    when "recipe.created", "recipe.favorited", "recipe.commented"
      recipe.image.url
    when "user.followed"
      user.picture_url
    end
    return img
  end

  def subject_view_path
    url = case self.action
    when "recipe.created", "recipe.favorited", "recipe.commented"
      recipe.view_path
    when "user.followed"
      user.view_path
    end
    return url
  end

  def icon_class
    url = case self.action
    when "recipe.created"
      "fa fa-cutlery"
    when "recipe.favorited"
      "fa fa-heart"
    when "recipe.commented"
      "fa fa-comment"
    when "user.followed"
      "fa fa-rss"
    end
    return url

  end

end
