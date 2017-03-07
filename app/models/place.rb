require 'place/geocoding'
require 'place/place_auditing'
require 'place/place_translations_auditing'
require 'place/place_background_translation'
require 'place/place_model_helpers'
require 'validators/custom_validators'
require 'auto_translation/auto_translate'
require 'sanitize'

class Place < ActiveRecord::Base
  include AutoTranslate
  include PlaceBackgroundTranslation
  include PlaceTranslationsAuditing
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
  validate :end_date, :is_after_start_date?, if: 'event'

  def is_after_start_date?
    if end_date < start_date
      errors.add(:expiration_date, I18n.t('.end_date_before_start_date'))
    end
  end

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [:update, :create], only: [:description] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :sanitize_descriptions, on: [:create, :update]
  after_validation :enforce_ssl_on_urls, on: [:create, :update], if: 'homepage.present?'
  before_create :geocode_with_nodes, unless: 'lat_lon_present?'
  before_update :geocode_with_nodes, if: :address_changed?
  after_create :enqueue_auto_translation
  after_create :set_description_reviewed_flags

  ## EVENT STUFF
  scope :all_events, -> { where(event: true) }
  scope :ongoing_events, -> { all_events.where("end_date > ? AND start_date < ?", Date.today, Date.today) }
  scope :future_events, -> { all_events.where("start_date > ?", Date.today) }
  scope :past_events, -> { all_events.where("end_date < ?", Date.today) }

  def past_event?
    event && end_date < Date.today
  end

  def ongoing_event?
    event && start_date < Date.today && end_date > Date.today
  end

  def future_event?
    event && start_date > Date.today
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
  # TODO factor this out?
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
    {
      id: id,
      address: address,
      phone: phone,
      email: email,
      name: name,
      homepage: self.homepage,
      homepage_full_domain: homepage,
      description: reviewed_description.html_safe,
      translation_auto_translated: translation_from_current_locale.auto_translated,
      translation_reviewed: translation_from_current_locale.reviewed,
      category_names: category_names.join(' | '),
      categories: category_ids,
      reviewed: reviewed
    }
  end
end
