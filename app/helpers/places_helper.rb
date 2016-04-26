module PlacesHelper
  def all_categories
    categories = []
    Place.all.each {|place| categories << place.tag_list}

    return categories.flatten.uniq
  end
end
