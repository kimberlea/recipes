class Location < ActiveRecord::Base
  include SchemaSync::Model
  include QuickScript::Model
  include APIUtils::Validation

  field :place_type, type: Integer
  field :city, type: String
  field :admin, type: String
  field :country, type: String
  field :country_iso2, type: String
  field :latitude, type: Float
  field :longitude, type: Float
  field :postal_code, type: String
  field :population, type: Integer
  field :uuid, type: String

  timestamps!

  index :uuid

  PLACE_TYPES = {city: 10}
  enum_methods! :place_type, PLACE_TYPES

  scope :with_name_like, lambda {|nm|
    ns = "%#{nm}%"
    where("city ILIKE ? OR admin ILIKE ?", ns, ns)
  }
  scope :with_ids, lambda {|*ids|
    where("id IN (?)", ids.flatten)
  }

  def self.import_from_csv(opts)
    require 'csv'
    file = opts[:file]
    CSV.foreach(file, headers: true) do |row|
      state = row['state_name']
      city = row['city']
      uuid = "C|US|#{state}|#{city}"
      pop = row['population'].to_i
      next if pop < 10000
      l = Location.new
      l.place_type! :city
      l.uuid = uuid
      l.city = city
      l.admin = state
      l.country = "United States of America"
      l.country_iso2 = "US"
      l.latitude = row['lat']
      l.longitude = row['lng']
      l.postal_code = row['zip'].split(" ").first if row['zip'].present?
      l.population = pop
      l.save
      puts l.inspect
    end
  end

  def full_name
    "#{city}, #{admin}"
  end

  def as_indexed_json(opts={})
    ret = {}
    ret['id'] = id.to_s
    ret['city'] = city
    ret['admin'] = admin
    ret['country'] = country
    ret['point'] = {'lat' => latitude.to_f, 'lon' => longitude.to_f}
    return ret
  end

  def to_api(opts={})
    ret = {}
    ret[:id] = self.id.to_s
    ret[:city] = self.city
    ret[:admin] = self.admin
    ret[:full_name] = self.full_name
    return ret
  end

end
