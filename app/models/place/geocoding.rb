module PlaceGeocoding
  PROBLEMATIC_CITIES = %w[Berlin]

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  def lat_lon_present?
    latitude.present? && longitude.present?
  end

  def geocode_with_nodes
    results = Geocoder.search(address).map { |res| OpenStruct.new(res.data) }
    unless results.any?
      errors.add(:address, :address_not_found)
      return false
    end
    node_geoms = results.select { |result| result.type == 'node' }
    other_geoms = results - node_geoms
    @geoms = node_geoms.any? ? node_geoms.first : other_geoms.first
    @geoms = PlaceGeocoding.prepare(search_results: @geoms)
    update_geofeatures_if_missing
  end

  def self.prepare(search_results:)
    # Prepare results
    s = OpenStruct.new search_results
    ret = {
      latitude: s.lat,
      longitude: s.lon,
      house_number: s.house_number || (s.address['house_number'] if s.address),
      street: s.street || s.road || s.pedestrian || (s.address['street'] || s.address['road'] || s.address['pedestrian'] if s.address),
      postal_code: s.postcode || (s.address['postcode'] if s.address),
      district: s.city_district || s.suburb || s.district || (s.address['city_district'] || s.address['suburb '] || s.address['district'] if s.address),
      city: s.city || s.town || s.village || (s.address['city'] || s.address['town'] || s.address['village'] if s.address),
      federal_state: s.state || (s.address['state'] || s.address['county'] if s.address),
      country: s.country || (s.address['country'] if s.address)
    }

    ret[:city] = ret[:federal_state] if PROBLEMATIC_CITIES.include? ret[:federal_state]
    ret
  end

  def update_geofeatures_if_missing
    @geoms.each do |geo_feature, value|
      self.send("#{geo_feature}=", value) unless self.send("#{geo_feature}").present?
    end
  end
end
