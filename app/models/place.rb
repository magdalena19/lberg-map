class Place < ActiveRecord::Base
  has_many :descriptions, :dependent => :delete_all
  geocoded_by :address
  accepts_nested_attributes_for :descriptions

  def address
    [self.street, self.house_number, self.postal_code, self.city].join(, )
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
