require 'geocoder'

module MassSeedAnnouncements
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

  # Generator methods for points and categories
  def self.generate_announcement
    Announcement.new( header: random_latin_string(rand(10..30)),
                      content: latin_lorem_ipsum(rand(50..300))
             ).save(validate: false)
  end

  def self.generate(number_of_announcements:)
    number_of_announcements.times.with_index do |i|
      generate_announcement
      STDOUT.write "\rGenerating Announcements: announcement #{i + 1}/#{number_of_announcements} created"
    end
  end
end
