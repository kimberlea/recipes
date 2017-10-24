class Photo < ActiveRecord::Base
  include SchemaSync::Model
  include QuickScript::Model
  include Metable

  field :dish_id, type: Integer
  field :comment_id, type: Integer

  embeds_one :image, class_name: "Common::ImageUpload"

  belongs_to :dish
  belongs_to :comment

  timestamps!

  scope :with_dish_id, lambda {|did|
    where(dish_id: did)
  }

  validate do
    errors.add(:dish_id, "Not assigned to dish.") if dish_id.blank? && comment_id.blank?
    errors.add(:image, "Image not saved.") if image.nil? || image.state?(:error)
  end

  def update_as_action!(opts)
    actor = opts[:actor]
    new_record = self.new_record?
    if new_record
      self.dish = Dish.find(opts[:dish_id]) if opts[:dish_id]
      self.comment = Comment.find(opts[:comment_id]) if opts[:comment_id]
      if (m = (dish || comment))
        # check if already has 10 photos
        if m.photos.count >= 10
          return {success: false, error: "You have already added 10 photos to this item."}
        end
      end
    end
    if opts[:image]
      self.image.delete_files if self.image
      res = Common::ImageUpload.store_source(opts[:image], style_type: 20)
      if !res[:success]
        raise res[:error]
      end
      self.image = upl = res[:data]
    end

    success = self.save
    if success
      begin
        meta_graph_updated_for(dish, comment)
      rescue => ex
        QuickScript.log_exception(ex)
      end
    end
    raise error_message if !success
    return {success: true, data: self, new_record: new_record}
  rescue => ex
    error = ex.message
    upl.delete_files if upl
    QuickScript.log_exception(ex)
    return {success: false, data: self, error: error}
  end

  def delete_as_action!(opts)
    self.image.delete_files if image
    self.destroy
    meta_graph_updated_for(dish, comment)
    return {success: true, data: self}
  end

  def to_api(opts={})
    ret = {}
    ret[:id] = id.to_s
    ret[:dish_id] = dish_id.to_s
    ret[:image] = image ? image.to_api : nil
    return ret
  end

end
