module PlacesHelper
	def generate_categories_filter_links(place)
		raw place.categories.map { |c| link_to c.name, category_path(c.name) }.join(', ')
	end
end
