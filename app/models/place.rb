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
  validates_presence_of :name, :street, :city, :postal_code
  validates :postal_code, format: { with: /\d{5}/, message: 'supply valid postal code (5 digits)' }

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [:update, :create] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode_with_nodes, if: :address_changed?, on: [:create, :update]
  before_validation :sanitize_descriptions, on: [:create, :update]

  if Rails.env != 'test'
    after_create :auto_translate
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
               latitude: latitude)
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
