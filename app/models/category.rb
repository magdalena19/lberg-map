class Category < ActiveRecord::Base
  translates :name
  globalize_accessors

  def self.id_for(category_string)
    category = Category.all.find do |cat|
      category_string.tr('_', ' ').casecmp(cat.name).zero?
    end
    category.id if category
  end
end
