require 'place/auto_translate'
require 'place/geocoding'

class Place < ActiveRecord::Base
  include PlaceAutoTranslation
  include Geocoding

  def self.reviewed
    Place.all.map(&:reviewed_version).compact
  end

  def self.with_reviewed_category(id)
    Place.all.map(&:reviewed_version).compact.find_all { |p| p.has_category?(id) }
  end

  ## VALIDATIONS
  validates :postal_code, format: { with: /\d{5}/, message: 'supply valid postal code (5 digits)' },
    if: 'postal_code.present?'
  validates :name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: 'email.present?'
  validates :phone, length: { minimum: 3, maximum: 20 }, if: 'phone.present?'
  validates :homepage, format: { with: /\A((http\:\/\/)|(www\.)|())\w+\.\w{2,}\z/ }, if: 'homepage.present?'

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [:update, :create] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :sanitize_descriptions, on: [:create, :update]
  before_create :geocode_with_nodes, unless: 'lat_lon_present?'
  before_update :geocode_with_nodes, if: :address_changed?
  after_create :auto_translate if Rails.env != 'test'

  def address
    ["#{street} #{house_number}", "#{postal_code} #{city}"].select { |e| !e.strip.empty? }.join(',')
  end

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
    end.merge!(address: address,
               description: reviewed_description.html_safe,
               categories: categories,
               longitude: longitude,
               latitude: latitude,
               reviewed: reviewed,
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
