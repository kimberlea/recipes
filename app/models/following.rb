class Following < ActiveRecord::Base
  include SchemaSync::Model
  include QuickScript::Model

  field :follower_id, type: Integer
  field :user_id, type: Integer

  belongs_to :user
  belongs_to :follower, class_name: "User"

  timestamps!

  validate do
    errors.add(:follower_id, "Follower not set.") if self.follower_id.blank?
    errors.add(:user_id, "User id not set.") if self.user_id.blank?
    if ( f = Following.where(follower_id: self.follower_id, user_id: self.user_id).first ) && f.id != self.id
      errors.add(:user, "You already follow this user!")
    end
    if follower_id == user_id
      errors.add(:user, "You can't follow yourself!")
    end
  end

  def update_as_action!(opts)
    actor = opts[:actor]
    new_record = self.new_record?
    if new_record
      self.follower_id = actor.id
      self.user_id = opts[:user_id]
    end
    success = self.save
    if success && new_record
      AppEvent.publish("user.followed", actor, {user: user})
    end
    return {success: success, data: self, error: self.error_message, new_record: new_record}
  end

  def delete_as_action!(opts)
    actor = opts[:actor]
    if actor.id != self.follower_id
      return {success: false, error: "You don't have permission."}
    end
    self.destroy
    return {success: true, data: self}
  end

  def to_api(lvl=:default, opts={})
    ret = {}
    ret[:id] = self.id.to_s
    ret[:follower_id] = self.follower_id.to_s
    ret[:user_id] = self.user_id.to_s
    ret[:errors] = self.errors.to_hash
    return ret

  end
end
