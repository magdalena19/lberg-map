require 'csv'
require 'date'

module PoiRepository
    def self.import_from_csv(file_name, city)
        generate_categories
        pois = CSV.read(file_name, {:col_sep => ';'})
        pois.each_with_index do |row, index|
          Place.new(id: index,
                    name: row[2],
                    street: parse_adress(row[10],0),
                    house_number: parse_adress(row[10],1),
                    postal_code: parse_adress(row[10],2), 
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
                   ).save(validate: false)
          debugger
          # Traverse through points
          #Place.find(index).translations.each do |translation|
          #  translation.without_versioning do
          #    translation.update_attributes(auto_translated: [true, false].sample, reviewed: [true, false].sample)
          #  end
          #end
        end
    

    end
    
    # Quick'n dirty, otherwise parse locale files for categories
    CATNAMES = ['playground', 'medical_support', 'legal_support', 'cafe', 'meeting_point', 'child_play']

    def self.generate_categories
      categories_in_db = Category.all.map(&:name)
      puts categories_in_db
      CATNAMES.each_with_index do | cat_name, index |
        unless categories_in_db.include? cat_name
          Category.create(
                          name_en: I18n.t("categories.#{cat_name}", locale: 'en'),
                          name_de: I18n.t("categories.#{cat_name}", locale: 'de'))
        end
      end  
    end
    # Helpers
    def self.nil_to_empty(value)
        if(value == nil) 
          ""
        else
          value
        end
    end

    def self.parse_adress(adress, part)
        if(adress!= nil) 
          adress.split(",")[part].tr(' ','')
        else
          ""
        end
    end  
    
    def self.get_category_ids(categories_string)
        #categories = CSV.parse(category_string, {:col_sep => ','})
        categories = categories_string.split(",")
        p categories
        categories_ids = []
        categories.each do |category|
            puts category
            categories_in_db = Category.all.map(&:name).map{ |c| c.downcase.gsub(' ', '_') }
            p categories_in_db
            if (!categories_in_db.include? category)
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

#-----------------------------------------------
#  DOMAIN_SUFFIXES = %w[de com org]
#
#  # Generator methods for points and categories
#  def self.generate_point(no_of_categories=3, bbox)
#    random_point = random_point_inside_bbox(bbox)
#    category_ids = Category.all.map(&:id)
#
#    place_id = Place.any? ? Place.last.id + 1 : 5000
#    web_presence = email_and_homepage
#
#    updated_at = Date.today - rand(0..365)
#    created_at = updated_at - rand(5..100)
#
#    Place.new(id: place_id,
#              name: 'bla', #latin_words(min_characters = rand(10..20)),
#              street: street_name,
#              house_number: house_number,
#              postal_code: german_postal_code,
#              city: @cityname,
#              phone: german_phone_number,
#              email: web_presence[:email],
#              homepage: web_presence[:homepage],
#              latitude: random_point[:latitude],
#              longitude: random_point[:longitude],
#              description_en: latin_lorem_ipsum(paragraphs = rand(2..5)),
#              description_de: latin_lorem_ipsum(paragraphs = rand(2..5)),
#              categories: category_ids.sample(rand(1..5)).join(','),
#              reviewed: [true, false].sample,
#              created_at: created_at,
#              updated_at: updated_at
#             ).save(validate: false)
#
#    # Traverse through points
#    Place.find(place_id).translations.each do |translation|
#      translation.without_versioning do
#        translation.update_attributes(auto_translated: [true, false].sample, reviewed: [true, false].sample)
#      end
#    end
#  end
#
#  # Quick'n dirty, otherwise parse locale files for categories
#  CATNAMES = ['playground', 'free_wifi', 'hospital', 'lawyer', 'cafe', 'meeting_point', 'child_play']
#
#  def self.generate_category
#    id_nr = Category.any? ? Category.last.id + 1 : 1
#    categories_in_db = Category.all.map(&:name)
#    cat_name = CATNAMES.pop
#    unless categories_in_db.include? cat_name
#      Category.create(id: id_nr,
#                      name_en: I18n.t("categories.#{cat_name}", locale: 'en'),
#                      name_de: I18n.t("categories.#{cat_name}", locale: 'de'))
#    end
#  end
#
#  def self.generate(number_of_points:, city:)
#    @cityname = city
#    unless bbox = bbox_from_cityname(@cityname)
#      error = "No boundingbox found in which to insert points! Have you supplied a geolocation (city, district, ...)?"
#      puts error
#      return error
#    end
#
#    # Create all categories listed in translation YAML files
#    generate_category while CATNAMES.any?
#
#    # Create n points
#    number_of_points.times.with_index do |i|
#      generate_point(rand(1..5), bbox)
#      STDOUT.write "\rGenerating points: point #{i + 1}/#{number_of_points} created"
#    end
    #  end
end
