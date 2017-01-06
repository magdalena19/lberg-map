require 'geocoder'

module MassSeedAnnouncements
  # Helpers
  def self.lat_word(characters = 10)
    word_pool = LoremIpsum.text.split(/\.|\,| /).select { |e| !e.empty? }.uniq
    words = []
    while words.join('').length < characters
      words << word_pool.sample
    end
    words.join(' ').capitalize
  end

  def self.arab_string(characters = 10)
    (0...characters).map { ('ا'..'غ').to_a[rand(28)] }.join
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

  # Generator methods for points and categories
  def self.generate_announcement
    announcement_id = Announcement.any? ? Announcement.last.id + 1 : 5000
    updated_at = Date.today - rand(0..365)
    created_at = updated_at - rand(5..100)
    user_ids = User.all.map(&:id)

    Announcement.new(header: lat_word(rand(10..30)),
                     content: latin_lorem_ipsum(rand(5..10)),
                     id: announcement_id,
                     created_at: created_at,
                     updated_at: updated_at,
                     user_id: user_ids.sample
                    ).save(validate: false)
  end

  def self.generate(number_of_announcements:)
    number_of_announcements.times.with_index do |i|
      generate_announcement
      STDOUT.write "\rGenerating Announcements: announcement #{i + 1}/#{number_of_announcements} created"
    end
  end
end
