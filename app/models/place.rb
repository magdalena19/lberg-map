class Place < ActiveRecord::Base
  ## RELATIONS
  has_many :categorizings
  has_many :categories, through: :categorizings

  ## VALIDATIONS
  validates_presence_of :name, :street, :city, :postal_code, :categories_list
  validates :postal_code, format: { with: /\d{5}/, message: "Supply valid postal code (5 digits)" }
  validate :has_valid_geocode?

  ## TRANSLATION
  translates :description
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode, :if => :address_changed?, on: [:create, :update]

  ## CATEGORY TAGGING
  def categories_list=(names)
    self.categories = names.split(',').map do |c|
      Category.where(name: c.strip).first_or_create!
    end
  end

  def categories_list
    self.categories.map { |c| c.name }
  end

  def self.tagged_with(category_name)
    obj = Category.find_by_name(category_name)
    obj && obj.places
  end

  ## GEOCODING
  def has_valid_geocode?
    address_string = "#{street} #{house_number}, #{postal_code}, #{city}"
    address = Geocoder.search(address_string).first

    unless address && address.type == "house"
      errors.add(:address, :address_not_found)
    end
  end

  def address
    "#{street} #{house_number}, #{postal_code} #{city}"
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
    self.description
  end
end
