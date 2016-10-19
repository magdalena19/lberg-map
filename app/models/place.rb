require 'place/auto_translate'
require 'place/geocoding'

class Place < ActiveRecord::Base
  include PlaceAutoTranslation
  include Geocoding

  def self.reviewed
    Place.all.map(&:reviewed_version).compact
  end

  def self.reviewed_with_category(id)
    Place.all.map(&:reviewed_version).compact.find_all { |p| p.has_category?(id) }
  end

  ## VALIDATIONS
  validates :postal_code, format: { with: /\d{5}/, message: 'supply valid postal code (5 digits)' },
    if: 'postal_code.present?'
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
  before_create :geocode_with_nodes, unless: 'lat_lon_present?'
  before_update :geocode_with_nodes, if: :address_changed?
  after_create :auto_translate

  ## VIRTUAL ATTRIBUTES
  def address
    ["#{street} #{house_number}", "#{postal_code} #{city}"].select { |e| !e.strip.empty? }.join(', ')
  end

  def homepage_full_domain
    if homepage
      homepage =~ /(http)/ ? homepage : 'http://' + homepage
    else
      ''
    end
  end

  ## MODEL AUDITING
  has_paper_trail on: [:create, :update], ignore: [:reviewed, :description]

  def new?
    versions.length == 1 && !reviewed
  end

  # TODO: bit smelly, returns nil in some cases...
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

  def destroy_all_updates(translation = nil)
    obj = translation ? translation : self
    updates = obj.reload.versions.find_all { |v| v.event == 'update' }
    updates.each(&:destroy)
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
               homepage_full_domain: homepage_full_domain,
               description: reviewed_description.html_safe,
               translation_auto_translated: translation_from_current_locale.auto_translated,
               translation_reviewed: translation_from_current_locale.reviewed,
               categories: categories,
               longitude: longitude,
               latitude: latitude,
               reviewed: reviewed)
  end

  def reviewed_description
    versions = translation_from_current_locale.versions
    if versions.length > 1
      versions.last.reify.description
    else
      description ? description : ''
    end
  end

  def translation_from_current_locale
    translations.find_by(locale: I18n.locale)
  end

  def edit_status
    if created_at == updated_at
      'new'
    else
      'edited'
    end
  end
end
