module Categorizing
  def category_for(id)
    category_ids.include?(id.to_s)
  end

  def category_ids
    categories.split(',')
  end

  def set_categories
    res = []
    category_names.each do |category_name|
      matches = match_existing(category_name: category_name)
      if matches.any?
        res << matches
      else
        new_category = map.categories.create(name: category_name, marker_color: 'purple', marker_icon_class: 'fa-star', marker_shape: 'square')
        res << new_category
      end
    end

    self.categories = res.flatten.uniq
  end

  def category_names
    categories_string.split(/;|,/).map(&:strip).sort
  end

  private

  def match_existing(category_name:)
    return [] unless map.categories.any?
    # Traverse all categories on map and check if any translation includes category name
    map.categories.all.select do |category|
      translated_names = category.translations.map(&:name)
      translated_names.include? category_name
    end
  end
end
