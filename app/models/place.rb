require 'place/auto_translate'
require 'place/geocoding'
require 'sanitize'

class Place < ActiveRecord::Base
  include PlaceAutoTranslation
  include Geocoding
  include Sanitization

  def self.reviewed
    Place.all.map(&:reviewed_version).compact
  end

  def self.reviewed_with_category(id)
    Place.all.map(&:reviewed_version).compact.find_all { |p| p.category_for(id) }
  end

  def self.places_to_review
    unreviewed_places = Place.all.find_all(&:unreviewed_version)
    places_to_review = unreviewed_places.map do |p|
      p.reviewed_version || p.unreviewed_version
    end
    places_to_review.sort_by(&:updated_at).reverse
  end

  ## VALIDATIONS
  validates :postal_code, format: { with: /\A\d{5}\z/, message: 'supply valid postal code (5 digits)' }, if: 'postal_code.present?'
  validates :name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: 'email.present?'
  validates :phone, format: { with: /\A((?![a-zA-Z]).){3,20}\z/ }, if: 'phone.present?'
  validates :homepage, format: { with:
    %r[\A​(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)\z] }, if: 'homepage.present?'

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [:update, :create] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :sanitize_descriptions, on: [:create, :update]
  after_validation :secure_homepage_link, on: [:create, :update]
  before_create :geocode_with_nodes, unless: 'lat_lon_present?'
  before_update :geocode_with_nodes, if: :address_changed?
  after_create :auto_translate, if: :empty_description?
  after_create :set_description_reviewed_flags

  def empty_description?
    translations.map { |t| t.description.nil? || t.description.empty? }.include? true
  end

  def set_description_reviewed_flags
    translations.each do |translation|
      translation.without_versioning do
        translation.update_attributes(reviewed: reviewed ? true : false)
      end
    end
  end

  ## VIRTUAL ATTRIBUTES
  def address
    ["#{street} #{house_number}", "#{postal_code} #{city}"].select { |e| !e.strip.empty? }.join(', ')
  end

  def protocol_prefix?
    ['https://', 'http://', 'www.'].map { |prefix| homepage.start_with? prefix }.include? true
  end

  def secure_homepage_link
    return nil if homepage.nil? || homepage.empty?

    if protocol_prefix?
      self.homepage = homepage.gsub 'www.', 'https://'
      self.homepage = homepage.gsub 'http://', 'https://'
    else
      self.homepage = 'https://' + homepage
    end
  end

  ## MODEL AUDITING
  has_paper_trail on: [:create, :update], ignore: [:reviewed, :description]

  def new?
    versions.length == 1 && !reviewed
  end

  def reviewed_version
    if versions.length > 1
      versions[1].reify
    elsif reviewed
      self
    end
  end

  def unreviewed_version
    self if versions.length > 1 || new?
  end

  def reviewed_description
    translation = translation_from_current_locale
    if translation.versions.count > 1
      translation.versions[1].reify.description
    else
      translation.reviewed ? translation.description : ''
    end
  end

  def translation_from_current_locale
    translations.find_by(locale: I18n.locale)
  end

  def destroy_all_updates(translation = nil)
    obj = translation ? translation : self
    updates = obj.reload.versions.find_all { |v| v.event == 'update' }
    updates.each(&:destroy)
  end

  ## CATEGORIES
  def category_for(id)
    category_ids.include?(id.to_s)
  end

  def category_names
    category_ids.map { |id| Category.find(id.to_s).name }
  end

  def category_ids
    categories.split(',').sort
  end

  def categories
    self[:categories].split(',').sort.join(',')
  end

  ## SANITIZE
  def sanitize_descriptions
    I18n.available_locales.each do |locale|
      column = "description_#{locale}"
      send(column + '=', sanitize(send(column)))
    end
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
               homepage_full_domain: homepage,
               description: reviewed_description.html_safe,
               translation_auto_translated: translation_from_current_locale.auto_translated,
               translation_reviewed: translation_from_current_locale.reviewed,
               categories: categories,
               longitude: longitude,
               latitude: latitude,
               reviewed: reviewed)
  end
end
