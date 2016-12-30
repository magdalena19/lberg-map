class Category < ActiveRecord::Base
  translates :name
  globalize_accessors

  def self.points_in_categories
    points_in_category = { 'All points' => Place.pluck(:reviewed).count }

    categories_in_points = Place.where(reviewed: true)
                            .pluck(:categories)
                            .map { |c| c.split (', ') }
                            .flatten
                            .map(&:to_i)

    Category.all.each do |category|
      points_in_category[category.name] = categories_in_points.count(category.id)
    end
    
    points_in_category
  end

  def points_in_category
    Category.points_in_categories[name]
  end

  def self.id_for(category_string)
    category = Category.all.find do |cat|
      category_string.gsub('_', ' ').casecmp(cat.name) == 0
    end
    category.id if category
  end
end
