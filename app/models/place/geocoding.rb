module Geocoding
  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  def lat_lon_present?
    latitude.present? && longitude.present?
  end

  def geocode_with_nodes
    results = Geocoder.search(address)
    unless results.any?
      errors.add(:address, :address_not_found)
      return false
    end
    node_geoms = results.select { |result| result.type == 'node' }
    other_geoms = results - node_geoms
    if node_geoms.any?
      self.latitude = node_geoms.first.latitude
      self.longitude = node_geoms.first.longitude
    else
      self.latitude = other_geoms.first.latitude
      self.longitude = other_geoms.first.longitude
    end
  end
end
