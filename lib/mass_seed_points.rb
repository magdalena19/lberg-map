require 'geocoder'
require 'faker'

# Module written in order to generate seed data
module MassSeedPoints
  # Helpers
  def self.n_random_digits(n = 5, from = 0, to = 9)
    Array.new(n) { rand(from..to) }.join('')
  end

  def self.house_number
    n_random_digits(rand(1..2), 1).to_s + ('a'..'h').to_a.sample * rand(0..1)
  end

  def self.german_postal_code(region = 10)
    region.to_s + n_random_digits(3).to_s
  end

  def self.german_phone_number
    area_code = '0' + n_random_digits(1) + '0'
    mobile = '0' + n_random_digits(3)
    gap = ['', ' / ', ' - '].sample
    number = n_random_digits(7)

    [area_code, mobile].sample + gap + number
  end

  def self.arab_string(characters = 10)
    (0...characters).map { ('ا'..'غ').to_a.sample }.join
  end

  def self.arab_lorem_ipsum(words = 100)
    lorem_ipsum = (0..words).map { arab_string(rand(2..26)) }.join(' ')
    "<b>#{arab_string(rand(5..10))}</b> <br><br>" + lorem_ipsum
  end

  def self.bbox_from_cityname(cityname)
    result = Geocoder.search(cityname).first
    result && result.data["boundingbox"].map(&:to_f) || nil
  end

  def self.random_point_inside_bbox(bbox)
    lats = [bbox[0], bbox[1]]
    longs = [bbox[2], bbox[3]]
    { latitude: rand(lats.min..lats.max), longitude: rand(longs.min..longs.max) }
  end

  # Generator methods for points and categories
  def self.update_place_translations_attr(place:)
    place.translations.each do |translation|
      translation.without_versioning do
        translation.update_attributes(auto_translated: [true, false].sample, reviewed: [true, false].sample)
      end
    end
  end

  def self.generate_point(bbox)
    random_point = random_point_inside_bbox(bbox)
    updated_at = Date.today - rand(0..365)
    created_at = updated_at - rand(5..100)
    categories = Category.all
    @place = Place.create(name: Faker::Hipster.word.capitalize,
                          street: Faker::Address.street_name,
                          house_number: house_number,
                          postal_code: german_postal_code,
                          city: @cityname,
                          phone: german_phone_number,
                          email: Faker::Internet.email,
                          homepage: Faker::Internet.url,
                          latitude: random_point[:latitude],
                          longitude: random_point[:longitude],
                          description_en: Faker::Hipster.paragraph(rand(1..2)),
                          description_de: Faker::Hipster.paragraph(rand(1..2)),
                          categories: categories.sample(rand(1..3)).map(&:name).join(','),
                          reviewed: [true, false].sample,
                          created_at: created_at,
                          updated_at: updated_at)
    update_place_translations_attr(place: @place)
  end

  # Quick'n dirty, otherwise parse locale files for categories

  def self.populate_predefined_categories
    Category.create(name_en: 'Playground', locale: 'en',
                    name_de: 'Spielplatz', locale: 'de')
    Category.create(name_en: 'Lawyer', locale: 'en',
                    name_de: 'Anwalt', locale: 'de')
    Category.create(name_en: 'Hospital', locale: 'en',
                    name_de: 'Krankenhaus', locale: 'de')
  end

  def self.generate(number_of_points:, city:)
    @cityname = city
    bbox = bbox_from_cityname(@cityname)
    unless bbox
      raise ArgumentError, 'No boundingbox found in which to insert points! Have you supplied a geolocation (city, district, ...)?'
    end

    # Create all categories listed in translation YAML files
    populate_predefined_categories

    # Create n points
    number_of_points.times.with_index do |i|
      generate_point(bbox)
      STDOUT.write "\rGenerating points: point #{i + 1}/#{number_of_points} created"
    end
  end
end
