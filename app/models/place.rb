class Place < ActiveRecord::Base
  include Place::AutoTranslator

  ## RELATIONS
  has_many :categorizings
  has_many :categories, through: :categorizings

  ## VALIDATIONS
  validates_presence_of :name, :street, :city, :postal_code
  validates :postal_code, format: { with: /\d{5}/, message: 'upply valid postal code (5 digits)' }
  validate :valid_geocode?

  ## TRANSLATION
  translates :description
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode, if: :address_changed?, on: [:create, :update]
  after_create :auto_translate
  before_validation :sanitize_descriptions, on: [:create, :update]

  ## CATEGORY TAGGING
  def category_ids=(ids)
    clean_ids = ids.reject(&:empty?)
    if clean_ids == []
      categories.destroy_all
    else
      self.categories = clean_ids.map do |id|
        Category.where(id: id.to_i).first
      end
    end
  end

  def self.tagged_with(id)
    category = Category.find(id)
    category && category.places
  end

  ## GEOCODING
  def valid_geocode?
    address_string = "#{street} #{house_number}, #{postal_code}, #{city}"
    address = Geocoder.search(address_string).first
    errors.add(:address, :address_not_found) unless address && address.type == 'house'
  end

  def address
    "#{street} #{house_number}, #{postal_code} #{city}"
  end

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  ## AUTOTRANSLATE
  def auto_translate
    available_locales = I18n.available_locales
    # GUESS NATIVE LANGUAGE (longest description)
    translations_with_descriptions = translations.select { |t| !t.description.nil? }
    native_translation = translations_with_descriptions.sort_by do |t|
      t.description.length
    end.last
    translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    if translator && native_translation
      languages_of_empty_descriptions = available_locales - [native_translation.locale]
      languages_of_empty_descriptions.each do |missing_language|
        prefix = I18n.send('translate', "auto_translation_prefix_#{missing_language}")
        auto_translation = translator.failsafe_translate(native_translation.description,
                                                native_translation.locale.to_s,
                                                missing_language.to_s)
        full_text = "#{prefix} #{auto_translation}"
        translations.find_by(locale: missing_language).update(description: full_text)
      end
    end
  end

  ## SANITIZE
  def sanitize_descriptions
    I18n.available_locales.each do |locale|
      column = "description_#{locale}"
      send(column + '=', sanitize(send(column)))
    end
  end

  def sanitize(html)
    Rails::Html::WhiteListSanitizer.new.sanitize(
      html,
      tags: %w[br u i b li ul ol hr font a],
      attributes: %w[align color size href]
    )
  end

  ## PROPERTIES
  def geojson
    {
      id: id,
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [longitude, latitude],
      },
      properties: properties,
    }
  end

  def properties
    attributes.each do |_key, value|
      { key: value }
    end.merge!( address: address,
                description: description,
                categories: categories.map { |c| c.id }
              )
  end
end
