class User < ActiveRecord::Base
  include SchemaSync::Model
  include QuickAuth::Authentic
  mount_uploader :picture, PictureUploader

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :picture, type: String
  field :bio, type: String
  field :is_superadmin, type: :boolean, default: false
  field :notification_frequency, type: Integer, default: 1
  field :last_notification_at, type: Time
  field :flags, type: Integer, array: true, default: []

  timestamps!
  quick_auth_authentic!

  has_many :dishes, class_name: "Dish", foreign_key: :creator_id

  attr_accessor :api_request_scope, :following

  NOTIFICATION_FREQUENCIES = {none: 0, daily: 1, weekly: 2}
  FLAGS = {share_your_dish: 1}

  validate do
    errors.add(:first_name, "Enter your first name.") if self.first_name.blank?
    errors.add(:last_name, "Enter your last name.") if self.last_name.blank?
    errors.add(:email, "Enter your email address.") if self.email.blank?
    if (user = User.find_by_email(email)) && user.id != self.id
      errors.add(:email, "This email address already exists!")
    end
    errors.add(:password, "Enter your password.") if self.password_required?
    if self.password.present? && self.password.length < 4
      errors.add(:password, "Your password must be at least 4 characters.")
    end
  end

  ## CLASS METHODS(User, viewing all users)

  def self.find_by_email(email)
    return nil if email.nil?
    User.where(email: email.strip.downcase).first
  end

  def self.authenticate(email, password)
    if (user = User.find_by_email(email.strip.downcase)) && user.authenticated?(password)
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
    self.email = opts[:email].strip.downcase if opts[:email]
    self.password = opts[:password] if opts[:password]
    self.bio = opts[:bio] if opts[:bio]
  

    # save and return response
    success = self.save
    if success == true
      if new_record
        begin
          # start following featured people
          self.follow_featured_users!
        rescue => ex
          Rails.logger.info ex.message
        end
      end
    else
      error = self.errors.values.flatten.first
    end
    return {success: success, data: self, error: error, new_record: new_record}
  end

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def view_path(opts={})
    str = "/member/#{id}/#{full_name.parameterize}"
    if opts[:full] == true
      str = "http://dishfave.com#{str}"
    end
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

  def reaction_to(dish, build=false)
    r = UserReaction.where(user_id: self.id, dish_id: dish.id).first
    if r.nil? && build == true
      r = UserReaction.new(user_id: self.id, dish_id: dish.id)
    end
    return r
  end

  def picture_url
    if self.picture.nil? || self.picture.url.nil?
      "https://dishfave.com/assets/default-user.png"
    else
      self.picture.thumb.url
    end
  end

  def favorites_count
    UserReaction.where(is_favorite: true).where("dish_id IN (SELECT id FROM dishes WHERE creator_id=?)", self.id).count
  end

  def notification_period
    case self.notification_frequency
    when 1
      1.day
    when 2
      1.week
    else
      0
    end
  end

  def has_flag?(val)
    (self.flags || []).include?(val)
  end

  def set_flag!(val)
    return if val.nil?
    self.flags << val.to_i if !self.has_flag?(val)
    self.save(validate: false)
    return val
  end

  def follow_featured_users!
    return if !Rails.env.production?
    fuids = [1]
    fuids.each do |uid|
      f = Following.new
      f.follower_id = self.id
      f.user_id = uid
      f.save
    end
  end

  def send_reset_password_email!
    self.reset_perishable_token!
    html = MailMaker.parse_template("account/reset_password", user: self)
    mail = QuickNotify::Mailer.app_email(to: self.email, subject: "Reset your password on Dishfave", html_body: html)
    mail.deliver_now
  end

  def to_api(lvl=:default, opts={})
    actor = opts[:actor]
    ret = {}
    ret[:id] = self.id.to_s
    ret[:first_name] = self.first_name
    ret[:last_name] = self.last_name
    ret[:full_name] = self.full_name
    ret[:favorites_count] = self.favorites_count
    ret[:email] = self.email
    ret[:bio] = self.bio
    ret[:view_path] = self.view_path
    ret[:picture_url] = self.picture_url

    if lvl == :full
      ret[:flags] = (self.flags || []) if actor == self
    end
    ret[:errors] = self.errors.to_hash if self.errors.any?

    if following
      ret[:following] = following.to_api(:embedded)
    end

    return ret
  end
end
