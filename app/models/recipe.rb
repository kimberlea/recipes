class Recipe < ActiveRecord::Base
  include SchemaSync::Model
  mount_uploader :image, RecipeImageUploader

  field :title, type: String
  field :serving_size, type: Integer, rename_from: :serving_size
  field :description, type: String
  field :ingredients, type: String
  field :directions, type: String
  field :tags, type: String, array: true
  #field :prep_time, type: String
  field :prep_time_mins, type: Integer
  field :image, type: String
  field :creator_id, type: Integer
  field :is_private, type: :boolean, default: false

  field :search_vector, type: :tsvector

  belongs_to :creator, class_name: "User"

  has_many :user_reactions

  timestamps!

  scope :serves_count, lambda {|count|
    where("serving_size > ?", count)
  }
  scope :is_public, lambda {
    where(is_private: false)
  }

  after_save :update_search_vector

  validate do
    errors.add(:title, "Please enter a title for this recipe.") if self.title.blank?
    errors.add(:serving_size, "Enter serving size.") if self.serving_size.blank?
    errors.add(:ingredients, "Enter recipe ingredients.") if self.ingredients.blank?
    errors.add(:directions, "Enter recipe directions.") if self.directions.blank?
    errors.add(:creator, "Enter who created this recipe.") if self.creator_id.blank?
    errors.add(:prep_time_mins, "Enter how long this recipe takes.") if self.prep_time_mins.blank?
    errors.add(:image, "Please add a image for your recipe.") if self.image.blank? || self.image.url.blank?
  end

  def view_path
    return "/recipe/#{id}"
  end

  def tags_to_str
    return "" if tags.nil?
    tags.join(", ")
  end

  def markdown_render(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
    markdown.render(text)
  end

  def ingredients_html
    return "" if self.ingredients.blank?
    return markdown_render(self.ingredients)
  end

  def directions_html
    return "" if self.directions.blank?
    return markdown_render(self.directions)
  end

  def favorites_count
    UserReaction.where(recipe_id: self.id, is_favorite: true).count
  end

  def prep_time_details
    return {} if prep_time_mins.nil?
    hrs = prep_time_mins.to_i / 60
    mins = prep_time_mins.to_i % 60
    str = hrs > 0 ? "#{hrs}h #{mins}m" : "#{mins} mins"
    return {hours: hrs, minutes: mins, text: str}
  end

  def update_search_vector
    v = "#{title} #{description} #{tags.join(" ")}"
    conn = self.class.connection
    sql = Recipe.send(:sanitize_sql, ["UPDATE recipes SET search_vector = to_tsvector(?) WHERE id=?", v, id])
    conn.execute(sql)
  end

  def to_api
    ret = {}
    ret[:id] = self.id.to_s
    ret[:title] = self.title
    ret[:created_at] = self.created_at.to_i
    ret[:errors] = self.errors.to_hash if self.errors.any?
    ret[:ingredients] = self.ingredients
    ret[:directions] = self.directions
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
