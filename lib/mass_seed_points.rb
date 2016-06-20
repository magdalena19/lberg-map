require 'geocoder'

module MassSeedPoints
  # Helpers
  def self.random_latin_string(characters = 10)
    (0...characters).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def self.random_arab_string(characters = 10)
    (0...characters).map { ('ا'..'غ').to_a[rand(28)] }.join
  end

  def self.latin_lorem_ipsum(words = 100)
    lorem_ipsum = (0..words).map { random_latin_string(rand(2..26)) }.join(' ')
    "<b>#{random_latin_string(rand(5..10))}</b> <br><br>" + lorem_ipsum
  end

  def self.arab_lorem_ipsum(words = 100)
    lorem_ipsum = (0..words).map { random_arab_string(rand(2..26)) }.join(' ')
    "<b>#{random_arab_string(rand(5..10))}</b> <br><br>" + lorem_ipsum
  end

  def self.bbox_from_cityname(cityname)
    result = Geocoder.search(cityname).first
    result && result.boundingbox.map(&:to_f) || nil
  end

  def self.random_point_inside_bbox(bbox)
    latitudes = [bbox[0], bbox[1]]
    longitudes = [bbox[2], bbox[3]]
    { latitude: rand(latitudes.min..latitudes.max),
      longitude: rand(longitudes.min..longitudes.max) }
  end

  def self.n_random_digits(n = 5, from = 0, to = 9)
    n.times.map { rand(from..to) }.join('')
  end

  # Generator methods for points and categories
  def self.generate_point(no_of_categories=3, bbox)
    random_point = random_point_inside_bbox(bbox)
    category_ids = Category.all.map(&:id)
    place_id = Place.last.id + 1

    Place.new(id: place_id,
              name: random_latin_string(rand(10..20)),
              street: random_latin_string(rand(5..10)).capitalize + '-Straße',
              house_number: n_random_digits(rand(1..3), 1),
              postal_code: n_random_digits,
              city: @cityname,
              latitude: random_point[:latitude],
              longitude: random_point[:longitude],
              description_en: latin_lorem_ipsum(rand(10..90)),
              description_de: latin_lorem_ipsum(rand(10..90)),
              description_fr: latin_lorem_ipsum(rand(10..90)),
              description_ar: arab_lorem_ipsum(rand(10..90)),
              reviewed: [true,false].sample
             ).save(validate: false)

    no_of_categories.times do
      Categorizing.create(category_id: category_ids.shuffle.pop,
                          place_id: place_id)
    end
  end

  def self.generate_category
    id_nr = Category.any? && (Category.all.map(&:id).max + 1) || 1
    Category.create(id: id_nr,
                    name_en: random_latin_string,
                    name_de: random_latin_string,
                    name_fr: random_latin_string,
                    name_ar: random_arab_string
                   )
  end

  def self.generate(number_of_points:, city:)
    @cityname = city
    unless bbox = bbox_from_cityname(@cityname)
      error = "No boundingbox found in which to insert points! Have you supplied a geolocation (city, district, ...)?"
      puts error
      return error
    end

    # Create up to 10 categories
    amount_of_new_categories = 10 - Category.all.count
    amount_of_new_categories.times { generate_category }

    # Create n points
    number_of_points.times.with_index do |i|
      generate_point(rand(1..5), bbox)
      STDOUT.write "\rGenerating points: point #{i + 1}/#{number_of_points} created"
    end
  end
end
