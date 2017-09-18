class UserReaction < ActiveRecord::Base
  include SchemaSync::Model
  include QuickAuth::Authentic

  field :user_id, type: Integer
  field :dish_id, type: Integer
  field :is_favorite, type: :boolean
  field :rating, type: Integer

  belongs_to :dish
  belongs_to :user

  timestamps!

  scope :with_user_id, lambda {|uid|
    where(user_id: uid)
  }
  scope :with_dish_id, lambda {|did|
    where(dish_id: did)
  }

  validate do
    errors.add(:user_id, "User id is not set.") if self.user_id.blank?
    errors.add(:dish_id, "Dish id is not set.") if self.dish_id.blank?
    if ( u = UserReaction.where(user_id: self.user_id, dish_id: self.dish_id).first ) && u.id != self.id
      errors.add(:user, "You already liked this dish!")
    end
  end

  def self.react_as_action!(opts)
    actor = opts[:actor]
    r = UserReaction.with_user_id(actor.id).with_dish_id(opts[:dish_id])
    r = r.first || UserReaction.new
    res = r.update_as_action!(opts)
    return res
  end

  def update_as_action!(opts)
    actor = opts[:actor]
    favorited = false
    self.user_id = actor.id
    self.dish_id = opts[:dish_id] if opts[:dish_id]
    if opts[:is_favorite].present?
      self.is_favorite = QuickScript.parse_bool(opts[:is_favorite])
      favorited = self.is_favorite
    end
    self.rating = opts[:rating].to_i if opts.key?(:rating)

    saved = self.save
    if saved
      # update dish
      if (dish = self.dish)
        dish.update_meta
        dish.creator.update_meta
        if favorited
          AppEvent.publish("dish.favorited", actor, dish: dish)
        end
      end
    end
    return { success: saved, data: self}
  end

  def delete_as_action!(opts)
    return {success: false}
  end

  def to_api(lvl=:default, opts={})
    ret = {}
    ret[:id] = self.id.to_s
    ret[:dish_id] = self.dish_id.to_s
    ret[:user_id] = self.user_id.to_s
    ret[:rating] = self.rating
    ret[:is_favorite] = self.is_favorite
    ret[:errors] = self.errors.to_hash
    return ret
  end

end
