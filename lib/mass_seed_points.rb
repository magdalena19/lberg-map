require 'geocoder'

module MassSeedPoints
  # Helpers
  def self.n_random_digits(n = 5, from = 0, to = 9)
    n.times.map { rand(from..to) }.join('')
  end

  def self.latin_word(min_characters = 10)
    word_pool = LoremIpsum.text.split(/\.|\,| /).select { |e| !e.empty? }.uniq
    words = []
    while words.join('').length < min_characters
      words << word_pool.sample
    end
    words.join(' ').capitalize
  end

  def self.arab_string(characters = 10)
    (0...characters).map { ('ا'..'غ').to_a.sample }.join
  end

  def self.street_name
    latin_word(rand(3..6)).capitalize + ['-', ' '].sample + ['Straße', 'Weg', 'Platz'].sample
  end

  def self.house_number
    n_random_digits(rand(1..2), 1).to_s + ('a'..'h').to_a.sample*rand(0..1)
  end

  def self.german_postal_code(region = 10)
    region.to_s + n_random_digits(3).to_s
  end

  def self.latin_lorem_ipsum(paragraphs = 3)
    lorem_ipsum = []
    paragraphs.times do
      lorem_ipsum << LoremIpsum.random(paragraphs: 1)
    end
    lorem_ipsum.join('<br>')
  end

  def self.arab_lorem_ipsum(words = 100)
    lorem_ipsum = (0..words).map { arab_string(rand(2..26)) }.join(' ')
    "<b>#{arab_string(rand(5..10))}</b> <br><br>" + lorem_ipsum
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

  # Generator methods for points and categories
  def self.generate_point(no_of_categories=3, bbox)
    random_point = random_point_inside_bbox(bbox)
    category_ids = Category.all.map(&:id)
    place_id = Place.any? ? Place.last.id + 1 : 5000

    updated_at = Date.today - rand(0..365)
    created_at = updated_at - rand(5..100)

    Place.new(id: place_id,
              name: latin_word(min_characters = rand(10..20)),
              street: street_name,
              house_number: house_number,
              postal_code: german_postal_code,
              city: @cityname,
              latitude: random_point[:latitude],
              longitude: random_point[:longitude],
              description_en: latin_lorem_ipsum(paragraphs = rand(2..5)),
              description_de: latin_lorem_ipsum(paragraphs = rand(2..5)),
              description_fr: latin_lorem_ipsum(paragraphs = rand(2..5)),
              description_ar: arab_lorem_ipsum(words = rand(10..90)),
              categories: category_ids.sample(rand(1..5)).join(','),
              reviewed: [true,false].sample,
              created_at: created_at,
              updated_at: updated_at
             ).save(validate: false)
  end

  def self.generate_category
    id_nr = Category.any? ? Category.last.id + 1 : 1
    Category.create(id: id_nr,
                    name_en: latin_word(characters = 5),
                    name_de: latin_word(characters = 5),
                    name_fr: latin_word(characters = 5),
                    name_ar: arab_string(characters = 10)
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
