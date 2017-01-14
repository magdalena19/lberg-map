require 'place/geocoding'
require 'place/auditing'
require 'auto_translate'
require 'sanitize'

class Place < ActiveRecord::Base
  include AutoTranslate
  include PlaceGeocoding
  include PlaceAuditing
  include Sanitization

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
  after_create :enqueue_auto_translation
  after_create :set_description_reviewed_flags

  def enqueue_auto_translation
    TranslationWorker.perform_async("Place", id)
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

  def attribute_for_map(attribute)
    !attribute.empty? ? attribute : I18n.t('places.not_set')
  end

  def properties
    {
      id: id,
      address: attribute_for_map(address),
      phone: attribute_for_map(phone),
      email: attribute_for_map(email),
      name: name,
      homepage: self.homepage,
      homepage_full_domain: homepage,
      description: reviewed_description.html_safe,
      translation_auto_translated: translation_from_current_locale.auto_translated,
      translation_reviewed: translation_from_current_locale.reviewed,
      categories: category_ids,
      reviewed: reviewed
    }
  end
end
