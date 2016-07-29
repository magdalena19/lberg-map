require 'auto_translator'

class Place < ActiveRecord::Base
  def self.reviewed
    Place.all.map(&:reviewed_version).compact
  end

  def self.with_reviewed_category(id)
    Place.all.map(&:reviewed_version).compact.find_all{ |p| p.has_category?(id) }
  end

  ## VALIDATIONS
  validates_presence_of :name, :street, :city, :postal_code
  validates :postal_code, format: { with: /\d{5}/, message: 'supply valid postal code (5 digits)' }

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [ :update, :create ] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode_with_nodes, if: :address_changed?, on: [:create, :update]
  after_create :auto_translate
  before_validation :sanitize_descriptions, on: [:create, :update]

  ## MODEL AUDITING
  has_paper_trail on: [:create, :update], ignore: [:reviewed, :description]

  def new?
    versions.length == 1 && !reviewed
  end

  def reviewed_version
    return versions.last.reify  if versions.length > 1  && reviewed
    return self                 if versions.length == 1 && reviewed
  end

  def unreviewed_version
    self if versions.length > 1 || (versions.length == 1 && !reviewed)
  end

  ## Language and autotranslation related stuff
  # Maybe refactor
  # Why obj.split(' ').length == 1 ?? raises error in case of one-word-description (no error handling)
  def emptyish?(obj)
    obj.nil? || obj.empty? || obj.split(' ').length == 1
  end

  def autotranslated_or_empty_descriptions
    translations.select { |t| t.auto_translated || emptyish?(t.description) }
  end

  def locales_of_empty_descriptions
    autotranslated_or_empty_descriptions.map(&:locale)
  end

  def translations_with_descriptions
    translations - autotranslated_or_empty_descriptions
  end

  def guess_native_language_description
    translations_with_descriptions.sort_by do |t|
      t.description.length
    end.last
  end

  def translate_empty_descriptions
    locales_of_empty_descriptions.each do |missing_locale|
      auto_translation = @translator.failsafe_translate(
        @native_translation.description,
        @native_translation.locale.to_s,
        missing_locale.to_s
      )
      translation = translations.find_by(locale: missing_locale)
      translation.without_versioning do
        translation.update_attributes(description: auto_translation,
                                      auto_translated: true,
                                      reviewed: false)
      end
    end
  end

  def auto_translate
    @native_translation = guess_native_language_description
    @translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    translate_empty_descriptions if @translator && @native_translation
  end

  ## CATEGORIES
  def has_category?(id)
    category_ids.include?(id.to_s)
  end

  def category_names
    category_ids.map { |id| Category.find(id.to_s).name }
  end

  def category_ids
    categories.split(',')
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
    description: reviewed_description.html_safe,
    categories: categories,
    longitude: longitude,
    latitude: latitude,
    )
  end

  def reviewed_description
    versions = translations.find_by(locale: I18n.locale).versions
    if versions.length > 1
      versions.last.reify.description
    else
      description
    end
  end

  def edit_status
    if created_at == updated_at
      'new'
    else
      'edited'
    end
  end
end
