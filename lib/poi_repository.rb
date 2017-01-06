require 'csv'
require 'date'

module PoiRepository
  def self.import_from_csv(file_name, city)
    generate_categories
    pois = CSV.read(file_name, {:col_sep => ';'})
    pois.each_with_index do |row|
      place = Place.create(name: row[2],
                           street: parse_address(row[10],0),
                           house_number: parse_address(row[10],1),
                           postal_code: parse_address(row[10],2), 
                           city: city,
                           phone: nil_to_empty(row[9]),
                           email: nil_to_empty(row[8]),
                           homepage: nil_to_empty(row[7]),
                           latitude: row[3],
                           longitude: row[4],
                           description_en: nil_to_empty(row[6]),
                           description_de: nil_to_empty(row[5]),
                           categories: get_category_ids(row[1]),
                           reviewed: true,
                           created_at: DateTime.now,
                           updated_at: DateTime.now
                          )
      # Traverse through points and set translations review state
      place.translations.each do |translation|
        translation.without_versioning do
          translation.update_attributes(auto_translated: false, reviewed: true)
        end
      end
    end
  end

  # Quick'n dirty, otherwise parse locale files for categories
  CATNAMES = ['playground', 'medical_support', 'legal_support', 'cafe', 'meeting_point', 'child_play']

  def self.generate_categories
    categories_in_db = Category.all.map(&:name)
    puts categories_in_db
    CATNAMES.each do |cat_name|
      unless categories_in_db.include? cat_name
        Category.create(
          name_en: I18n.t("categories.#{cat_name}", locale: 'en'),
          name_de: I18n.t("categories.#{cat_name}", locale: 'de'))
      end
    end  
  end

  # Helpers
  def self.nil_to_empty(value)
    return value.nil? ? "" : value
  end

  def self.parse_address(address, part)
    address.present? ? address.split(',')[part].tr(' ', '') : ""
  end  

  def self.get_category_ids(categories_string)
    categories = categories_string.split(",")
    categories_ids = []
    categories.each do |category|
      categories_in_db = Category.all.map(&:name).map{ |c| c.downcase.tr(' ', '_') }
      unless categories_in_db.include? category
        Category.create(
          name_en: I18n.t("categories.#{category}", locale: 'en'),
          name_de: I18n.t("categories.#{category}", locale: 'de'))
        categories_ids << Category.last.id
      else
        categories_ids << Category.id_for(category)
      end  
    end  
    categories_ids.join(',')
  end
end
