module PlacesHelper
  def generate_categories_filter_links(place)
    raw place.categories.map { |c| link_to c.name, category_path(c.id) }.join(', ')
  end

  def address(place)
    "#{place.street} #{place.house_number}, #{place.postal_code} #{place.city}"
  end
end
