class AppEvent < ActiveRecord::Base
  include SchemaSync::Model

  field :action, type: String
  
  field :actor_id, type: Integer

  field :dish_id, type: Integer
  field :comment_id, type: Integer
  field :user_id, type: Integer

  field :meta, type: Hash, default: {}

  belongs_to :dish
  belongs_to :comment
  belongs_to :user
  belongs_to :actor, class_name: "User"

  timestamps!

  scope :relevant_for_user, lambda {|user|
    where("action IN (?)", ["dish.created", "dish.commented", "dish.favorited", "user.followed"]).where("(actor_id = ?) OR (user_id = ?) OR (dish_id IN (SELECT id FROM dishes WHERE dishes.creator_id=?)) OR (actor_id IN (SELECT user_id FROM followings WHERE followings.follower_id = ?))", user.id, user.id, user.id, user.id)
  }
  scope :not_with_actor, lambda {|user|
    where("actor_id != ?", user.id)
  }
  scope :created_after, lambda {|t|
    where("created_at > ?", t)
  }
  scope :with_any_action, lambda {|*val|
    where("action IN (?)", val)
  }

  def self.publish(action, actor, models, opts={})
    ev = self.new
    ev.action = action
    ev.actor_id = actor.id
    ev.dish = models[:dish]
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
    when "dish.created"
      "created a new dish, \"#{dish.title}\"."
    when "dish.favorited"
      "favorited the dish, \"#{dish.title}\"."
    when "dish.commented"
      "commented on the dish, \"#{dish.title}\"."
    when "user.followed"
      user_str = viewer == user ? "you" : user.full_name
      "started following #{user_str}."
    end
    return "#{actor_str} #{action_str}"
  end

  def body(opts={})
    summ = case self.action
    when "dish.created", "dish.favorited"
      dish.description
    when "dish.commented"
      comment.body
    when "user.followed"
      user.bio
    end
    return summ
  end

  def subject_image_url
    img = case self.action
    when "dish.created", "dish.favorited", "dish.commented"
      dish.image.thumb.url
    when "user.followed"
      user.picture_url
    end
    return img
  end

  def subject_view_path(opts={})
    url = case self.action
    when "dish.created", "dish.favorited", "dish.commented"
      dish.view_path(opts)
    when "user.followed"
      user.view_path(opts)
    end
    return url
  end

  def icon_class
    url = case self.action
    when "dish.created"
      "fa fa-cutlery"
    when "dish.favorited"
      "fa fa-heart"
    when "dish.commented"
      "fa fa-comment"
    when "user.followed"
      "fa fa-rss"
    end
    return url

  end

end
