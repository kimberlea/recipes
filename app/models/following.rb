class Following < ActiveRecord::Base
  include SchemaSync::Model

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

  def to_api
    ret = {}
    ret[:id] = self.id.to_s
    ret[:errors] = self.errors.to_hash
    return ret

  end
end
