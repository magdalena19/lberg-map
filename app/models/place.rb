class Place < ActiveRecord::Base
  has_many :descriptions, :dependent => :delete_all
  accepts_nested_attributes_for :descriptions

  geocoded_by :address
  before_validation :geocode, :if => :address_changed?

  validates_presence_of :name, :longitude, :latitude, :street, :city, :postal_code, :categories
  validates :postal_code, format: { with: /\d{5}/, message: "Supply valid postal code (5 digits)" }

  def address
    "#{street} #{house_number}, #{postal_code}, #{city}"
  end

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  # def address_changed?
  #   attrs = %w(street house_number postal_code city)
  #   attrs.any?{|a| send "#{a}_changed?"}
  # end

  def geojson
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [self.latitude, self.longitude],
      },
      properties: {
        name: self.name,
        categories: self.categories,
      },
    }
  end
end
