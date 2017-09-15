class Comment < ActiveRecord::Base 
  include SchemaSync::Model
  include QuickScript::Model
  include APIUtils::Validation

  field :user_id, type: Integer 
  field :body, type: String
  field :dish_id, type: Integer

  belongs_to :user
  belongs_to :dish

  timestamps!

  scope :with_dish_id, lambda {|did|
    where(dish_id: did)
  }

  validate do
    # present
    errors.add(:body, "Enter a comment please.") if self.body.blank?
    errors.add(:user_id, "User id not set.") if self.user_id.blank?
    errors.add(:dish_id, "Dish id not set.") if self.dish_id.blank?

    # length
    validate_length_of(:body, "body")
  end

  def update_as_action!(opts) 
    actor = opts[:actor]
    new_record = self.new_record?
    if new_record
      self.dish_id = opts[:dish_id] if opts[:dish_id]
      self.user = actor
    end
    self.body = opts[:body] if opts[:body]

    saved = self.save
    if saved && new_record
      AppEvent.publish("dish.commented", actor, {comment: self, dish: self.dish})
    end
    return {success: saved, data: self, error: error_message, new_record: new_record}
  end

  def to_api(lvl=:default, opts={})
    ret = {}
    ret[:id] = self.id.to_s
    ret[:dish_id] = self.dish_id.to_s
    ret[:body] = self.body
    ret[:created_at] = self.created_at.to_i
    ret[:errors] = self.errors.to_hash
    if has_present_association?(:user)
      ret[:user] = user.to_api(:embedded)
    end
    return ret
  end

end
