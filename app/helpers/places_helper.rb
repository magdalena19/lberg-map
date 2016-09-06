module PlacesHelper
  def category_link(category_id)
    raw link_to Category.find(category_id).name, category_path(category_id)
  end

  def last_places_created
    Place.all.sort_by(&:created_at).reverse
  end

  def address(place)
    ["#{place.street} #{place.house_number}", "#{place.postal_code} #{place.city}"].select(&:present?).join(', ')
  end
end
