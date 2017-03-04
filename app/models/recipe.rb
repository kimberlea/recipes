class Recipe < ActiveRecord::Base
  include SchemaSync::Model
  mount_uploader :image, RecipeImageUploader

  field :title, type: String
  field :serving_size, type: Integer, rename_from: :serving_size
  field :description, type: String
  field :ingredients, type: String
  field :directions, type: String
  field :tags, type: String, array: true
  field :prep_time, type: String
  field :image, type: String
  field :creator_id, type: Integer

  belongs_to :creator, class_name: "User"

  timestamps!

  scope :serves_count, lambda {|count|
    where("serving_size > ?", count)
  }

  validate do
    errors.add(:title, "Please enter a title for this recipe.") if self.title.blank?
    errors.add(:serving_size, "Enter serving size.") if self.serving_size.blank?
    errors.add(:ingredients, "Enter recipe ingredients.") if self.ingredients.blank?
    errors.add(:directions, "Enter recipe directions.") if self.directions.blank?
    errors.add(:creator, "Enter who created this recipe.") if self.creator_id.blank?
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
    ret[:prep_time] = self.prep_time
    ret[:view_path] = self.view_path

    return ret
  end
end
