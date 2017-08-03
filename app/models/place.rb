require 'place/categorizing'
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
  include Categorizing
  include PlaceBackgroundTranslation
  include PlaceTranslationsAuditing
  include PlaceGeocoding
  include PlaceAuditing
  include Sanitization
  include CustomValidators
  include PlaceModelHelpers

  extend TimeSplitter::Accessors
  split_accessor :start_date
  split_accessor :end_date

  # PLACE COLORS
  COLORS_AVAILABLE = [
    'red', 'darkorange', 'orange', 'yellow', 'darkblue', 'purple', 'violet', 'pink', 'darkgreen', 'green', 'lightgreen'
  ].freeze

  def self.available_colors
    COLORS_AVAILABLE
  end

  ## ASSOCIATIONS
  belongs_to :map
  has_many :place_category, dependent: :nullify
  has_many :categories, through: :place_category, dependent: :nullify

  ## VALIDATIONS
  validates :name, presence: true
  validates :postal_code, german_postal_code: true, if: 'postal_code.present?'
  validates :email, email_format: true, if: 'email.present?'
  validates :phone, phone_number_format: true, if: 'phone.present?'
  validates :homepage, url_format: true, if: 'homepage.present?'
  validate :end_date, :is_after_start_date?, if: 'start_date.present? && end_date.present?'
  validates :color, inclusion: { in: COLORS_AVAILABLE }

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
  after_create :enqueue_auto_translation, if: 'map.auto_translate'
  after_create :set_description_reviewed_flags
  after_save :set_categories

  # EVENT STUFF
  scope :all_events, -> { where(event: true) }
  scope :ongoing_events, -> { all_events.where("end_date > ? AND start_date < ?", Date.today, Date.today) }
  scope :future_events, -> { all_events.where("start_date > ?", Date.today) }
  scope :past_events, -> { all_events.where("end_date < ?", Date.today) }

  def daterange
    [start_date, end_date].map { |date| date.strftime('%d.%m.%Y %H:%M') if date }.join(' - ')
  end

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
    address = ["#{street} #{house_number}", "#{postal_code} #{city}"].select { |e| !e.strip.empty? }.join(', ')
    address + " (#{district})" if district
    return address
  end

  ## MODEL AUDITING
  # Hack categories auditing which is experimental for n:n-relations => audit categories_string, which is DB column
  has_paper_trail on: [:create, :update], ignore: [:reviewed, :description, :categories]

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
      is_event: event,
      start_date: start_date,
      end_date: end_date
    }
  end

  def properties
    {
      name: name,
      address: address,
      district: district,
      federal_state: federal_state,
      country: country,
      phone: phone,
      email: email,
      homepage: homepage,
      description: reviewed_description&.html_safe,
      category_names: categories.map(&:name).join(' | '),
      is_event: event,
      color: color,
      reviewed: reviewed
    }
  end
end
