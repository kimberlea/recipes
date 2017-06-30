class Dish < ActiveRecord::Base
  include SchemaSync::Model
  include APIUtils::Validation
  mount_uploader :image, DishImageUploader

  field :title, type: String
  field :serving_size, type: Integer, rename_from: :serving_size
  field :description, type: String
  field :ingredients, type: String
  field :directions, type: String
  field :purchase_info, type: String
  field :tags, type: String, array: true
  #field :prep_time, type: String
  field :prep_time_mins, type: Integer
  field :image, type: String
  field :is_private, type: :boolean, default: false
  field :is_recipe_private, type: :boolean, default: false

  field :search_vector, type: :tsvector

  field :cached_favorites_count, type: Integer

  field :creator_id, type: Integer

  belongs_to :creator, class_name: "User"

  has_many :user_reactions

  timestamps!

  scope :serves_count, lambda {|count|
    where("serving_size > ?", count)
  }
  scope :is_public, lambda {
    where(is_private: false)
  }
  scope :with_tag, lambda {|tag|
    where("? = ANY(tags)", tag)
  }

  after_save :update_search_vector

  validate do
    # presence
    errors.add(:title, "Please enter a title for this dish.") if self.title.blank?
    errors.add(:description, "Please enter a description for this dish.") if self.description.blank?
    if self.is_private != true && self.is_recipe_private == true && self.purchase_info.blank?
      errors.add(:purchase_info, "You must enter purchase info if you hide the recipe for a public dish. If it's not available for purchase, just make the entire dish private.")
    end
    if self.purchase_info.blank? && self.directions.blank?
      errors.add(:purchase_info, "You must at least enter purchase info if you don't enter directions.")
      errors.add(:directions, "You must enter directions if you don't enter how to purchase.")
    end
    if self.directions.present?
      errors.add(:ingredients, "Enter recipe ingredients.") if self.ingredients.blank?
      errors.add(:prep_time_mins, "Enter how long this recipe takes.") if self.prep_time_mins.blank?
    end
    errors.add(:serving_size, "Enter serving size.") if self.serving_size.blank?
    errors.add(:creator, "Enter who created this dish.") if self.creator_id.blank?
    if !Rails.env.test?
      errors.add(:image, "Please add a image for your dish.") if self.image.blank? || self.image.url.blank?
    end

    # lengths
    validate_length_of(:title, "title", 1, 1000)
    validate_length_of(:description, "description")
    validate_length_of(:directions, "directions")
    validate_length_of(:ingredients, "ingredients")
    validate_length_of(:purchase_info, "purchase info")
  end

  def view_path(opts={})
    str = "/dish/#{id}"
    if title.present?
      str += "/#{title.parameterize}"
    end
    if opts[:full] == true
      str = "https://dishfave.com#{str}"
    end
    return str
  end

  def tags_to_str
    return "" if tags.nil?
    tags.join(", ")
  end

  def markdown_render(text)
    return "" if text.blank?
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
    markdown.render(text)
  end

  def description_html
    return markdown_render(self.description)
  end

  def ingredients_html
    str = self.ingredients
    str = str.split("\n").collect { |l|
      if !(l.strip.start_with?("-") || l.strip.start_with?("*"))
        "- #{l}"
      else
        l
      end
    }.join
    return markdown_render(str)
  end

  def directions_html
    return markdown_render(self.directions)
  end

  def purchase_info_html
    return markdown_render(self.purchase_info)
  end

  def favorites_count
    UserReaction.where(dish_id: self.id, is_favorite: true).count
  end

  def prep_time_details
    return {} if prep_time_mins.nil?
    hrs = prep_time_mins.to_i / 60
    mins = prep_time_mins.to_i % 60
    str = hrs > 0 ? "#{hrs}h #{mins}m" : "#{mins} mins"
    return {hours: hrs, minutes: mins, text: str}
  end

  def has_directions?
    self.directions.present?
  end

  def has_purchase_info?
    self.purchase_info.present?
  end

  def has_prep_time?
    self.prep_time_mins.present? && self.prep_time_mins > 0
  end

  def created_by?(user)
    return false if user.nil?
    return self.creator_id == user.id
  end

  def update_search_vector
    v = "#{title} #{description} #{(tags || []).join(" ")}"
    conn = self.class.connection
    sql = Dish.send(:sanitize_sql, ["UPDATE dishes SET search_vector = to_tsvector(?) WHERE id=?", v, id])
    conn.execute(sql)
  end

  def update_meta
    # compute likes count
    self.cached_favorites_count = self.favorites_count
    self.save(validate: false)
  rescue => ex
    Rails.logger.info ex.message
    Rails.logger.info ex.backtrace.join("\n\t")
  end

  def to_api
    ret = {}
    ret[:id] = self.id.to_s
    ret[:title] = self.title
    ret[:created_at] = self.created_at.to_i
    ret[:errors] = self.errors.to_hash if self.errors.any?
    ret[:purchase_info] = self.purchase_info
    ret[:tags] = self.tags
    ret[:description] = self.description
    ret[:serving_size] = self.serving_size
    ret[:prep_time_mins] = self.prep_time_mins
    ret[:view_path] = self.view_path
    ret[:is_private] = self.is_private
    ret[:image] = self.image

    return ret
  end
end
