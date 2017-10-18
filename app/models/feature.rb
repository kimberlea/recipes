class Feature < ActiveRecord::Base
  include SchemaSync::Model
  include QuickScript::Model
  include Metable
  include QuickJobs::Processable
  include QuickScript::PunditModel

  field :start_time, type: Time
  field :end_time, type: Time
  field :base_price, type: Integer
  field :billable_amount, type: Integer
  field :is_cancelled, type: :boolean

  field :cancelled_at, type: Time
  field :finalized_at, type: Time

  field :dish_id, type: Integer
  field :invoice_id, type: Integer
  field :creator_id, type: Integer

  belongs_to :creator, class_name: "User"
  belongs_to :dish
  belongs_to :invoice

  timestamps!
  processable!

  scope :with_dish_id, lambda {|did|
    where(dish_id: did)
  }
  scope :with_invoice_id, lambda {|iid|
    where(invoice_id: iid)
  }
  scope :is_active, lambda {
    now = Time.now
    where("is_cancelled IS NOT TRUE").where("start_time < ?", now).where("end_time > ?", now)
  }
  scope :is_finalized, lambda {
    where("finalized_at IS NOT NULL")
  }
  scope :needs_finalizing, lambda {
    now = Time.now
    where("finalized_at IS NULL").where("end_time < ? OR (is_cancelled = TRUE AND cancelled_at < ?)", now, now)
  }

  validate do
    errors.add(:start_time, "Start time not set.") if start_time.blank?
    errors.add(:end_time, "End time not set.") if end_time.blank?
    errors.add(:end_time, "End time not valid.") if start_time && end_time && end_time < start_time

    errors.add(:base_price, "Price not valid.") if base_price.blank? || base_price < 0
    errors.add(:dish, "Dish not set.") if dish_id.blank?
    errors.add(:creator, "Creator not set.") if creator_id.blank?
    if dish
      # check if dish already featured
      if Feature.with_dish_id(dish_id).is_active.count > 0
        errors.add(:dish, "This dish already has an active feature.")
      end
    end
    if finalized_at.present?
      errors.add(:invoice, "Dish must be invoiced to be finalized.") if invoice_id.blank?
    end
  end

  def self.process_needs_finalizing(opts={})
    process_each!(needs_finalizing, id: "process_needs_finalizing") do |m|
      m.finalize!
    end
  end

  def update_as_action!(opts)
    actor = opts[:actor]
    new_record = self.new_record?
    if new_record
      # check if payment method present
      if !actor.has_valid_payment_method?
        return {success: false, error: "You must have a valid payment method on file to purchase a feature.", error_type: "PaymentMethodNeeded"}
      end
      self.creator = actor
      self.start_time = Time.now
      self.end_time = self.start_time.advance(days: 7)
      self.base_price = 1999
      self.billable_amount = base_price
      self.dish = Dish.find(opts[:dish_id])
    end
    success = self.save
    if success
      begin
        if opts.key?(:is_feature_autorenewable)
          self.dish.update_attribute(:is_feature_autorenewable, QuickScript.parse_bool(opts[:is_feature_autorenewable]))
        end
        meta_graph_updated_for(dish)
      rescue => ex
        QuickScript.log_exception(ex)
      end
    end
    return {success: success, data: self, error: error_message, new_record: new_record}
  end

  def cancel_as_action!(opts)
    actor = opts[:actor]
    dish_policy = policy_for(dish)
    dish_policy.authorize! :manage_features?
    return {success: true, data: self} if self.is_cancelled
    self.is_cancelled = true
    self.cancelled_at = Time.now
    success = self.save
    if success
      meta_graph_updated_for(dish)
    end
    return {success: success, data: self, error: error_message}
  end

  def is_active?
    t = Time.now
    return false if is_cancelled == true
    return true if t > start_time && t < end_time
  end

  def is_finalized?
    self.finalized_at.present?
  end

  def finalize!
    # check if can finalize
    raise "Already finalized" if is_finalized?
    raise "Cannot finalize active feature" if is_active?
    # determine billable amount
    self.update_billable_amount!
    # add to open invoice
    inv = Invoice.open_for_user(creator, {create: true})
    raise "Invoice could not be created." if inv.nil?
    self.invoice_id = inv.id
    # set finalized
    self.finalized_at = Time.now
    success = self.save
    raise "Dish could not be finalized: #{error_message}" if !success
    # try to renew feature
    begin
      if dish.is_feature_autorenewable && is_cancelled != true
        f = Feature.new
        f.base_price = base_price
        res = f.update_as_action!(dish_id: dish_id, actor: creator)
        raise res[:error] if res[:success] != true
      end
    rescue => ex
      QuickScript.log_exception(ex)
    end
    meta_graph_updated_for(dish)
    return true
  end

  def update_billable_amount!
    if is_cancelled == true
      ratio = (cancelled_at - start_time).to_f / (end_time - start_time)
      self.billable_amount = (base_price * ratio).to_i
    else
      self.billable_amount = self.base_price
    end
    self.save(validate: false)
  end

  def to_api(opts={})
    ret = {}
    ret[:id] = self.id.to_s
    ret[:start_time] = self.start_time.to_i
    ret[:end_time] = self.end_time.to_i
    ret[:base_price] = self.base_price
    ret[:billable_amount] = self.billable_amount
    ret[:is_active] = self.is_active?
    ret[:is_cancelled] = self.is_cancelled
    ret[:created_at] = self.created_at.to_i
    return ret
  end

end
