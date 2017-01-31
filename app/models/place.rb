require 'place/geocoding'
require 'place/auditing'
require 'auto_translate'
require 'sanitize'
require 'custom_validators'
require 'place_model_helpers'

class Place < ActiveRecord::Base
  include AutoTranslate
  include PlaceGeocoding
  include PlaceAuditing
  include Sanitization
  include CustomValidators
  include PlaceModelHelpers

  ## VALIDATIONS
  validates :name, presence: true
  validates :postal_code, german_postal_code: true, if: 'postal_code.present?'
  validates :email, email_format: true, if: 'email.present?'
  validates :phone, phone_number_format: true, if: 'phone.present?'
  validates :homepage, url_format: true, if: 'homepage.present?'

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [:update, :create] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :sanitize_descriptions, on: [:create, :update]
  after_validation :enforce_ssl_on_urls, on: [:create, :update], if: 'homepage.present?'
  before_create :geocode_with_nodes, unless: 'lat_lon_present?'
  before_update :geocode_with_nodes, if: :address_changed?
  after_create :enqueue_auto_translation
  after_create :set_description_reviewed_flags

  def enqueue_auto_translation
    TranslationWorker.perform_async('Place', id)
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
