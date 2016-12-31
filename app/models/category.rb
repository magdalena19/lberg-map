class Category < ActiveRecord::Base
  translates :name
  globalize_accessors

  def number_of_reviewed_places
    Place.reviewed_with_category(id).count
  end

  def self.id_for(category_string)
    category = Category.all.find do |cat|
      category_string.gsub('_', ' ').casecmp(cat.name) == 0
    end
    category.id if category
  end
end
