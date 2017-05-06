class User < ActiveRecord::Base
  include SchemaSync::Model
  include QuickAuth::Authentic
  mount_uploader :picture, PictureUploader

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :picture, type: String
  field :bio, type: String


  timestamps!
  quick_auth_authentic!

  has_many :recipes, class_name: "Recipe", foreign_key: :creator_id


  validate do
    errors.add(:first_name, "Enter your first name.") if self.first_name.blank?
    errors.add(:last_name, "Enter your last name.") if self.last_name.blank?
    errors.add(:email, "Enter your email address.") if self.email.blank?
    if (user = User.find_by_email(email)) && user.id != self.id
      errors.add(:email, "This email address already exists!")
    end
    errors.add(:password, "Enter your password.") if self.password_required?
  end

  ## CLASS METHODS(User, viewing all users)

  def self.authenticate(email, password)
    if (user = User.find_by_email(email)) && user.authenticated?(password)
      return user
    else
      return nil
    end

  end

  ## MEMBER/INSTANCE METHODS(@user, user, single user)

  def update_as_action!(opts)
    new_record = self.new_record?
    if new_record
      # things needed ONLY if it's a create
    end

    # things for create or update
    self.first_name = opts[:first_name] if opts[:first_name]
    self.last_name = opts[:last_name] if opts[:last_name]
    self.email = opts[:email] if opts[:email]
    self.password = opts[:password] if opts[:password]
    self.bio = opts[:bio] if opts[:bio]
  

    # save and return response
    success = self.save
    if success == false
      error = self.errors.values.flatten.first
    end
    return {success: success, data: self, error: error, new_record: new_record}
  end

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def view_path
    str = "/member/#{id}"
    return str
  end

  def following_of(user)
    Following.where(follower_id: self.id, user_id: user.id).first
  end

  def following_by(user)
    Following.where(follower_id: user.id, user_id: self.id).first
  end

  def followings_of_me
    Following.where(user_id: self.id)
  end

  def followings_by_me
    Following.where(follower_id: self.id)
  end

  def reaction_to(recipe, build=false)
    r = UserReaction.where(user_id: self.id, recipe_id: recipe.id).first
    if r.nil? && build == true
      r = UserReaction.new(user_id: self.id, recipe_id: recipe.id)
    end
    return r
  end

  def picture_url
    if self.picture.nil? || self.picture.url.nil?
      "/assets/default-user.png"
    else
      self.picture.url
    end
  end

  def favorites_count
    UserReaction.where(is_favorite: true).where("recipe_id IN (SELECT id FROM recipes WHERE creator_id=?)", self.id).count
  end


  def to_api
    ret = {}
    ret[:id] = self.id.to_s
    ret[:first_name] = self.first_name
    ret[:last_name] = self.last_name
    ret[:email] = self.email
    ret[:bio] = self.bio
    ret[:errors] = self.errors.to_hash if self.errors.any?

    return ret
  end
end
