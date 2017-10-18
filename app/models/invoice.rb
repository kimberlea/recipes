class Invoice < ActiveRecord::Base
  include SchemaSync::Model
  include QuickScript::Model
  include QuickJobs::Processable

  field :ending_at, type: Time

  field :total, type: Integer
  field :amount_due, type: Integer
  field :amount_paid, type: Integer
  field :stripe_charge_ids, type: String, array: true

  field :finalized_at, type: Time
  field :charged_at, type: Time

  field :user_id, type: Integer

  belongs_to :user

  timestamps!
  processable!

  scope :is_open, lambda {|val=true|
    if val == true
      where("ending_at > ?", Time.now)
    else
      where("ending_at <= ?", Time.now)
    end
  }
  scope :with_user_id, lambda {|uid|
    where(user_id: uid)
  }
  scope :needs_finalizing, lambda {
    is_open(false).where("finalized_at IS NULL")
  }
  scope :needs_charging, lambda {
    where("finalized_at IS NOT NULL").where("amount_due > 0")
  }

  def self.open_for_user(user, opts={})
    inv = Invoice.with_user_id(user.id).is_open.first
    if inv.nil? && opts[:create] == true
      inv = Invoice.new
      inv.user = user
      inv.ending_at = Time.now.end_of_month
      inv.total = 0
      inv.amount_due = 0
      success = inv.save
      raise "Could not create invoice." if success == false
    end
    return inv
  end

  def self.process_needs_finalizing(opts={})
    process_each!(needs_finalizing, id: "process_needs_finalizing") do |m|
      m.finalize!
    end
  end

  def self.process_needs_charging(opts={})
    process_each!(needs_charging, id: "process_needs_charging") do |m|
      m.charge!
    end
  end

  def is_finalized?
    self.finalized_at.present?
  end

  def is_open?
    self.ending_at > Time.now
  end

  def stripe_charge_ids
    self[:stripe_charge_ids] ||= []
  end

  def finalize!
    raise "Already finalized" if is_finalized?
    raise "Cannot finalize open invoice" if is_open?
    # update total
    self.update_total!
    self.update_amount_due!
    self.finalized_at = Time.now
    success = self.save
    raise "Invoice could not be finalized: #{error_message}" if !success
    return true
  end

  def charge!
    # update amount due
    self.update_amount_due!
    raise "There is nothing due" if self.amount_due < 50
    cust = user.stripe_customer
    src = user.stripe_source

    charge = Stripe::Charge.create(
      amount: amount_due,
      currency: 'usd',
      description: "Invoice #{id}",
      metadata: {
        invoice_id: id
      },
      customer: cust.id,
      source: src.id
    )
    if charge.nil? || charge.paid != true
      raise "This charge could not be paid. The charge id is #{charge.id}."
    end
    self.stripe_charge_ids << charge.id
    self.charged_at = Time.now
    self.update_amount_due!
  end

  def update_total!
    raise "Already finalized." if is_finalized?
    fs = Feature.with_invoice_id(self.id).to_a
    sum = fs.reduce(0) {|sum, f| sum += f.billable_amount}
    self.total = sum
    self.save(validate: false)
  end

  def update_amount_due!
    self.update_amount_paid!
    self.amount_due = self.total - self.amount_paid
    if self.amount_due <= 50
      self.amount_due = 0
    end
    self.save(validate: false)
  end

  def update_amount_paid!
    # get all charges
    paid = 0
    stripe_charge_ids.each do |cid|
      c = Stripe::Charge.retrieve(cid)
      next if c.nil? || c.paid != true
      paid += c.amount
    end
    self.amount_paid = paid
    self.save(validate: false)
  end

  def to_api(opts={})
    ret = {}
    ret[:id] = id.to_s
    ret[:ending_at] = ending_at.to_i
    ret[:total] = total
    ret[:amount_due] = amount_due
    ret[:amount_paid] = amount_paid
    ret[:is_open] = is_open?
    ret[:created_at] = created_at.to_i
    return ret
  end

end
