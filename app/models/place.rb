require 'auto_translator'

class Place < ActiveRecord::Base
  ## RELATIONS
  has_many :categorizings
  has_many :categories, through: :categorizings

  ## VALIDATIONS
  validates_presence_of :name, :street, :city, :postal_code
  validates :postal_code, format: { with: /\d{5}/, message: 'upply valid postal code (5 digits)' }

  ## TRANSLATION
  translates :description
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode_with_nodes, if: :address_changed?, on: [:create, :update]
  after_create :auto_translate
  before_validation :sanitize_descriptions, on: [:create, :update]

  ## Language and autotranslation related stuff -> URGENTLY REFACTOR!
  def emptyish?(obj)
    obj.nil? || obj.empty? || obj.split(' ').length == 1
  end

  def autotranslated_or_empty_descriptions
    translations.select { |t| t.auto_translated || emptyish?(t.description) }
  end

  def translations_with_descriptions
    translations - autotranslated_or_empty_descriptions
  end

  def available_descriptions
    translations_with_descriptions.map(&:locale).join(', ')
  end

  def empty_descriptions
    autotranslated_or_empty_descriptions.map(&:locale).join(', ')
  end

  def self.places_with_missing_or_empty_translations
    all.select { |p| p.autotranslated_or_empty_descriptions.any? }
  end

  def guess_native_language_description
    # GUESS NATIVE LANGUAGE (simple: longest description)
    translations_with_descriptions.sort_by do |t|
      t.description.length
    end.last
  end

  def auto_translate
    available_locales = I18n.available_locales
    native_translation = guess_native_language_description
    translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    if translator && native_translation
      languages_of_empty_descriptions = available_locales - translations_with_descriptions.map(&:locale)
      languages_of_empty_descriptions.each do |missing_language|
        auto_translation = translator.failsafe_translate(native_translation.description,
        native_translation.locale.to_s,
        missing_language.to_s)
        translations.find_by(locale: missing_language).update(description: auto_translation, auto_translated: true)
      end
    end
  end

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
  def address
    "#{street} #{house_number}, #{postal_code} #{city}"
  end

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  def geocode_with_nodes
    results = Geocoder.search(address)
    unless results.any?
      errors.add(:address, :address_not_found)
      return false
    end
    node_geoms = results.select { |result| result.type == 'node' }
    other_geoms = results - node_geoms
    # Prefer point objects (locations, houses, etc.) given by nominatim
    if node_geoms.any?
      self.latitude = node_geoms.first.latitude
      self.longitude = node_geoms.first.longitude
      # ...else take lat/lon of other geoms (lines, etc.)
    else
      self.latitude = other_geoms.first.latitude
      self.longitude = other_geoms.first.longitude
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
    categories: categories.map(&:id),
    longitude: longitude,
    latitude: latitude,
    )
  end

  def edit_status
    if created_at == updated_at
      'new'
    else
      'edited'
    end
  end
end
