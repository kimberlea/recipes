class Dish < ActiveRecord::Base
  include SchemaSync::Model
  include QuickScript::Model
  include QuickScript::Stateable
  include APIUtils::Validation
  include QuickJobs::Processable
  include Metable
  include QuickScript::ElasticSearchable
  include QuickScript::PunditModel

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
  field :source_url, type: String

  field :is_purchasable, type: :boolean, default: false
  field :is_private, type: :boolean, default: false
  field :is_recipe_private, type: :boolean, default: false
  field :is_recipe_given, type: :boolean, default: true
  field :is_feature_autorenewable, type: :boolean, default: true

  field :search_vector, type: :tsvector

  field :cached_favorites_count, type: Integer
  field :cached_ratings_count, type: Integer
  field :cached_ratings_avg, type: Float

  field :creator_id, type: Integer
  field :feature_id, type: Integer

  belongs_to :creator, class_name: "User"
  belongs_to :feature

  has_many :user_reactions

  timestamps!
  state :active, 1
  state :deleted, 2
  stateable!
  processable!
  metable!

  attr_accessor :user_reaction, :api_request_scope

  scope :serves_count, lambda {|count|
    where("serving_size > ?", count)
  }
  scope :is_public, lambda {
    not_deleted.where(is_private: false)
  }
  scope :with_tag, lambda {|tag|
    where("? = ANY(tags)", tag)
  }
  scope :is_visible_by, lambda {|user|
    if user.nil?
      is_public
    else
      not_deleted.where("(dishes.creator_id = ?) OR (dishes.is_private <> 't')", user.id)
    end
  }
  scope :with_creator_id, lambda {|uid|
    where(creator_id: uid)
  }
  scope :with_creator_in_followings_of, lambda {|uid|
    where("creator_id IN (SELECT user_id from followings where followings.follower_id = ?)", uid)
  }
  scope :is_favorite_of, lambda {|uid|
    joins(:user_reactions).where("user_reactions.is_favorite = true and user_reactions.user_id = ?", uid)
  }
  scope :with_search_term, lambda {|term|
    where("search_vector @@ plainto_tsquery(?)", term)
  }
  scope :with_public_recipe, lambda {|val=true|
    where(is_recipe_given: true, is_recipe_private: false)
  }
  scope :is_purchasable, lambda {|val|
    where(is_purchasable: val)
  }

  #after_save :update_search_vector
  before_destroy :remove_image!

  settings(ELASTIC_CONFIG[:settings])
  mappings(&ELASTIC_CONFIG[:mappings][:dish])

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

    if is_purchasable == true
      errors.add(:purchase_info, "Please enter purchase info.") if purchase_info.blank?
    end

    # lengths
    validate_length_of(:title, "title", 1, 1000)
    validate_length_of(:description, "description")
    validate_length_of(:directions, "directions")
    validate_length_of(:ingredients, "ingredients")
    validate_length_of(:purchase_info, "purchase info")
  end

  def self.search_as_action!(opts)
    ctx = opts[:request_context]
    sr = scope_responder(ctx, {use_elastic: true})
    sr.result
  end

  def self.import_from_url_as_action!(opts)
    url = opts[:url]
    res = APIUtils.import_big_oven_recipe(url)
    return res
  end

  def update_as_action!(opts)
    actor = opts[:actor]
    new_record = self.new_record?
    if new_record
      self.creator = actor
      self.state! :active
    end
    policy_for(actor).authorize! :update?
    update_fields_from(opts, [
      :title,
      :serving_size,
      :description,
      :ingredients,
      :directions,
      :purchase_info,
      :prep_time_mins,
      :is_purchasable,
      :is_private,
      :is_recipe_private,
      :is_recipe_given
    ])
    if opts.key?(:tags)
      tags = QuickScript.parse_opts(opts[:tags])
      self.tags = tags.collect {|tag| tag.strip.downcase}
    end
    if opts.key?(:image)
      self.image = opts[:image]
    end
    success = self.save
    if success && new_record
      AppEvent.publish("dish.created", actor, {dish: self})
      meta_graph_updated_for(self, creator)
    end
    return {success: success, data: self, error: self.error_message, new_record: new_record}
  end

  def delete_as_action!(opts)
    actor = opts[:actor]
    policy_for(actor).authorize! :delete?
    self.set_state! :deleted
    meta_graph_updated_for(self, self.creator)
    return {success: true, data: self}
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

  def is_featured?(opts={})
    if opts[:reload] == true
      self.feature = Feature.with_dish_id(self.id).is_active.first
      if opts[:do_save] != false
        self.save(validate: false)
      end
    end
    feature_id.present?
  end

  def update_meta
    # compute likes count
    self.cached_favorites_count = self.favorites_count
    # compute ratings info
    ratings_scope = UserReaction.where(dish_id: self.id).where("rating IS NOT NULL")
    self.cached_ratings_count = ratings_scope.count
    self.cached_ratings_avg = ratings_scope.average(:rating)

    # feature
    self.is_featured?(reload: true, do_save: false)

    # save and index
    self.meta_updated_at = Time.now
    self.update_elastic
    self.save(validate: false)
  rescue => ex
    Rails.logger.info ex.message
    Rails.logger.info ex.backtrace.join("\n\t")
  end

  def as_indexed_json(opts={})
    ret = {}
    ret['id'] = id.to_s
    ret['title'] = title
    ret['description'] = description
    ret['tags'] = tags
    ret['locations'] = creator.locations.collect{|l| l.as_indexed_json}
    ret['creator'] = creator.as_indexed_json
    ret['creator_id'] = creator_id.to_s
    ret['state'] = state
    ret['is_private'] = is_private
    ret['created_at'] = created_at.iso8601
    ret['cached_favorites_count'] = cached_favorites_count || 0
    ret['prep_time_mins'] = prep_time_mins
    ret['is_recipe_given'] = is_recipe_given
    ret['is_recipe_private'] = is_recipe_private
    ret['is_purchasable'] = is_purchasable
    ret['is_featured'] = is_featured?
    return ret
  end

  def to_api(opts={})
    actor = opts[:actor]
    #puts "The actor is #{actor.inspect}"
    emb = opts[:embedded] || false
    view_full = policy_for(actor).view_full?
    show_recipe = is_recipe_private != true || view_full
    ret = {}
    ret[:id] = self.id.to_s
    ret[:title] = self.title
    ret[:description] = self.description
    ret[:is_purchasable] = self.is_purchasable
    ret[:purchase_info] = self.purchase_info
    ret[:tags] = self.tags || []
    ret[:serving_size] = self.serving_size
    ret[:prep_time_mins] = self.prep_time_mins
    ret[:prep_time_details] = self.prep_time_details
    ret[:is_private] = self.is_private
    ret[:is_recipe_given] = self.is_recipe_given
    ret[:image_url] = self.image ? self.image.url : nil
    ret[:is_recipe_private] = self.is_recipe_private
    ret[:is_private] = self.is_private
    ret[:is_featured] = self.is_featured?

    if show_recipe
      ret[:ingredients] = self.ingredients
      ret[:directions] = self.directions
    end

    ret[:view_path] = self.view_path
    ret[:view_url] = self.view_path(full: true)
    ret[:created_at] = self.created_at.to_i

    ret[:favorites_count] = self.cached_favorites_count
    ret[:ratings_count] = self.cached_ratings_count
    ret[:ratings_avg] = self.cached_ratings_avg.present? ? cached_ratings_avg.round(2) : nil
    ret[:errors] = self.errors.to_hash if self.errors.any?

    if !emb
      if show_recipe
        ret[:ingredients_html] = self.ingredients_html
        ret[:directions_html] = self.directions_html
      end
      ret[:description_html] = self.description_html
      ret[:purchase_info_html] = self.purchase_info_html
    end

    if has_present_association?(:creator)
      ret[:creator] = creator.to_api(embedded: true)
    end

    if user_reaction
      ret[:user_reaction] = user_reaction.to_api(:embedded)
    end
    return ret
  end

  class ScopeResponder < QuickScript::ModelScopeResponder
    def base_scope
      Dish.is_visible_by(actor)
    end

    def build_result
      ctx = request_context
      sks = ctx.scope.keys.collect(&:to_s)
      if options[:use_elastic] == true
        build_elastic_result
      else
        build_database_result
      end
    end

    def build_elastic_result
      ctx = request_context
      scope = ctx.scope
      ret = Dish.search_elastic(ctx.params) do |c|
        c.requested_includes = ["creator"]
        c.requested_scope = scope
        q = c.query
        scope = c.requested_scope
        scope.each do |key, val|
          case key.to_sym
          when :with_search_term
            q.add_simple_query_string(["title^2", "tags", "description", "creator.full_name"], val)
          when :with_creator_id
            q.add_term_filter("creator_id", val)
          when :with_location_near
            lat,lon,dist = val
            dist ||= "300km"
            q.add_filter("geo_distance", {
              "distance" => dist,
              "locations.point" => { "lat" => lat, "lon" => lon }
            })
          when :with_location_near_location_id
            dist ||= "300km"
            # find location
            l = Location.find(val)
            if l
              q.add_filter("geo_distance", {
                "distance" => dist,
                "locations.point" => { "lat" => l.latitude.to_f, "lon" => l.longitude.to_f }
              })
            end
          when :with_tag
            q.add_term_filter("tags", val)
          when :with_creator_in_followings_of
            # find follower ids
            ids = Following.where(follower_id: val).limit(1000).pluck(:user_id)
            q.add_term_filter("creator_id", ids)
          when :is_favorite_of
            # find favorite dishes
            ids = UserReaction.where(is_favorite: true, user_id: val).where("dish_id IS NOT NULL").limit(1000).pluck(:dish_id)
            q.add_term_filter("id", ids)
          when :with_public_recipe
            q.add_term_filter("is_recipe_given", true)
            q.add_term_filter("is_recipe_private", false)
          when :is_purchasable
            q.add_term_filter("is_purchasable", true)
          end # end case
        end # end scope each
        # add required scopes in
        q.add_term_filter("state", 1)
        if actor.nil?
          q.add_term_filter("is_private", false)
        else
          q.add_term_should("is_private", false)
          q.add_term_should("creator_id", actor.id.to_s)
        end
        if ctx.sort.present?
          ctx.sort.split(",").each do |s|
            q.add_sort(s.strip)
          end
        end
      end
      enhance_items(ret[:data]) if ret[:data].is_a?(Array)
      return ret
    end

    def enhance_items(models)
      ctx = request_context
      models = [models] if !models.is_a?(Array)
      ens = ctx.enhances
      if ens.include?("is_featured")
        models.each {|m| m.is_featured?(reload: true)}
      end
    end

  end

end
