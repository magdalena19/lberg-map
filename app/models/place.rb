class Place < ActiveRecord::Base
  ## RELATIONS
  has_many :categorizings
  has_many :categories, through: :categorizings
  has_many :descriptions, :dependent => :delete_all
  accepts_nested_attributes_for :descriptions

  ## VALIDATIONS
  validates_presence_of :name, :street, :city, :postal_code, :all_categories
  validates :postal_code, format: { with: /\d{5}/, message: "Supply valid postal code (5 digits)" }
  validate :has_valid_geocode?

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode, :if => :address_changed?, on: [:create, :update]

  ## CATEGORY TAGGING
  def all_categories=(names)
    self.categories = names.split(',').map do |c|
      Category.where(name: c.strip).first_or_create!
    end
  end

  def all_categories
    self.categories.map { |c| c.name }.join(', ')
  end

  ## GEOCODING
  def has_valid_geocode?
    address_string = "#{street} #{house_number}, #{postal_code}, #{city}"
    address = Geocoder.search(address_string).first

    unless address && address.type == "house"
      errors.add(:address, "could not be found!")
    end
  end

  def address
    "#{street} #{house_number}, #{postal_code}, #{city}"
  end

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  def geojson
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [self.latitude, self.longitude],
      },
      properties: properties,
    }
  end

  def properties
    self.attributes.each do |key, value|
      { key: value }
    end.merge!({ address: address, description: description_texts })
  end

  def description_texts
    self.descriptions.map(&:text)
  end
end
