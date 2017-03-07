module Categorizing
  def category_for(id)
    category_ids.include?(id.to_s)
  end

  def category_names
    category_ids.map { |id| Category.find(id.to_s).name }
  end

  def category_ids
    categories.split(',')
  end

  def categories
    self[:categories].split(',').sort.join(',')
  end

  def set_categories
    res = []
    place_categories.each do |category|
      matches = match_existing(category)
      if matches.any?
        res << matches.map(&:id)
      else
        new_category = Category.create name: category
        res << new_category.id
      end
    end

    self.categories = res.join(',')
  end

  private

  def place_categories
    categories.split(/;|,/).map(&:strip)
  end

  def match_existing(category_string)
    return [] unless Category.any?
    Category.all.select do |category|
      translated_names = category.translations.map(&:name)
      translated_names.include? category_string
    end
  end
end
