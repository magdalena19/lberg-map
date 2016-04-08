class Place < ActiveRecord::Base
  has_many :descriptions, :dependent => :delete_all
  accepts_nested_attributes_for :descriptions
  
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
