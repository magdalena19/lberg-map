require 'place/categorizing'
require 'place/geocoding'
require 'place/place_auditing'
require 'place/place_translations_auditing'
require 'place/place_model_helpers'
require 'place/twitter'
require 'validators/custom_validators'
require 'sanitize'

class Place < ActiveRecord::Base
  include Categorizing
  include PlaceTranslationsAuditing
  include PlaceGeocoding
  include PlaceAuditing
  include Sanitization
  include CustomValidators
  include PlaceModelHelpers
  include Twitter

  extend TimeSplitter::Accessors
  split_accessor :start_date
  split_accessor :end_date

  ## ASSOCIATIONS
  belongs_to :map
  has_many :place_category, dependent: :nullify
  has_many :categories, through: :place_category, dependent: :nullify
  has_many :place_attachments
  accepts_nested_attributes_for :place_attachments, reject_if: :all_blank, allow_destroy: true

  ## VALIDATIONS
  validates :name, presence: true
  validates :email, email_format: true, if: 'email.present?'
  validates :phone, phone_number_format: true, if: 'phone.present?'
  validates :homepage, url_format: true, if: 'homepage.present?'
  validates :name, length: { minimum: 3, maximum: 50 }
  validate :end_date, :is_after_start_date?, if: 'start_date.present? && end_date.present?'

  def is_after_start_date?
    if end_date < start_date
      errors.add(:expiration_date, I18n.t('.end_date_before_start_date'))
    end
  end

  def images
    place_attachments.map { |a| ActionController::Base.helpers.image_path(a.image) }
  end

  ## TRANSLATION
  translates :description, versioning: { gem: :paper_trail, options: { on: [:update, :create], only: [:description] } }
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :sanitize_descriptions, on: [:create, :update]
  after_validation :enforce_ssl_on_urls, on: [:create, :update], if: 'homepage.present?'
  before_create :geocode_with_nodes, unless: 'lat_lon_present?'
  before_update :geocode_with_nodes, if: Proc.new { street_changed? || city_changed? || house_number_changed? || postal_code_changed? }
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

  # Use this to pass conditional description text (either description itself or information that no translation is present)
  def displayed_description
    reviewed_description.present? ?
      reviewed_description.html_safe :
      I18n.t('.maps.show.places_list_panel.no_description_yet')
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

  def main_category
    categories&.first
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
      description: displayed_description,
      images: images,
      category_names: categories.map(&:name).map(&:to_s).sort.join(' | '),
      is_event: event,
      reviewed: reviewed,
      marker_color: main_category&.marker_color || 'violet',
      marker_icon_class: main_category&.marker_icon_class,
      marker_shape: main_category&.marker_shape || 'circle',
    }
  end
end
