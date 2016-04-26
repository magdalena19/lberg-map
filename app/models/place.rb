class Place < ActiveRecord::Base
  has_many :descriptions, :dependent => :delete_all
  geocoded_by :address # <- virtual attribute defined below
  after_validation :geocode

  accepts_nested_attributes_for :descriptions

  validates :name, presence: true
  validates :longitude, presence: true,
                        numericality: { less_than_or_equal_to: 90, greater_than_or_equal_to: -90 }
  validates :latitude, presence: true,
                       numericality: { less_than_or_equal_to: 180, greater_than_or_equal_to: -180 }
  validates :categories, presence: true

  def address
    ["#{self.street} #{self.house_number}", self.postal_code, self.city].join(", ")
  end

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
