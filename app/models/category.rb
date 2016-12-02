class Category < ActiveRecord::Base
  translates :name
  globalize_accessors

  def self.points_in_categories
    points_in_category = { 'All points' => Place.pluck(:reviewed).count }

		categories_in_points = Place.where(reviewed: true).pluck(:categories) do |categories|
      categories.split(',').map(&:to_i)
    end.flatten

    Category.all.each do |category|
      points_in_category[category.name] = categories_in_points.count(category.id)
    end

    points_in_category
  end

  def points_in_category
    Category.points_in_categories[name]
  end
end
