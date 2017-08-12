class UserReaction < ActiveRecord::Base
  include SchemaSync::Model
  include QuickAuth::Authentic

  field :user_id, type: Integer
  field :dish_id, type: Integer
  field :is_favorite, type: :boolean

  belongs_to :dish
  belongs_to :user

  timestamps!

  validate do
    errors.add(:user_id, "User id is not set.") if self.user_id.blank?
    errors.add(:dish_id, "Dish id is not set.") if self.dish_id.blank?
    if ( u = UserReaction.where(user_id: self.user_id, dish_id: self.dish_id).first ) && u.id != self.id
      errors.add(:user, "You already liked this dish!")
    end
  end

  def update_as_action!(opts)
    actor = opts[:actor]
    self.user_id = actor.id
    self.dish_id = opts[:dish_id] if opts[:dish_id]
    self.is_favorite = QuickScript.parse_bool(opts[:is_favorite]) if opts[:is_favorite].present?

    saved = self.save
    if saved
      # update dish
      if (dish = self.dish)
        dish.update_meta
      end
    end
    return { success: saved, data: self}
  end

  def delete_as_action!(opts)
    return {success: false}
  end

  def to_api
    ret = {}
    ret[:id] = self.id.to_s
    ret[:is_favorite] = self.is_favorite
    ret[:errors] = self.errors.to_hash
    return ret
  end

end
