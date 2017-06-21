class Comment < ActiveRecord::Base 
  include SchemaSync::Model

  field :user_id, type: Integer 
  field :body, type: String
  field :dish_id, type: Integer

  belongs_to :user
  belongs_to :dish


  timestamps!

  validate do
    errors.add(:body, "Enter a comment please.") if self.body.blank?
    errors.add(:user_id, "User id not set.") if self.user_id.blank?
    errors.add(:dish_id, "Dish id not set.") if self.dish_id.blank?
  end

  def to_api 
    ret = {}
    ret[:id] = self.id.to_s
    ret[:body] = self.body
    ret[:errors] = self.errors.to_hash
    return ret
  end

end
