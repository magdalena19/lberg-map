require 'validators/custom_validators'
require 'sanitize'

class Map < ActiveRecord::Base
  has_secure_password validations: false
  include CustomValidators
  include Sanitization

  has_many :places, dependent: :destroy
  has_many :categories, dependent: :destroy
  belongs_to :user

  before_validation :sanitize_description
  before_validation :sanitize_imprint
  before_validation lambda { password_digest = 'no password set' }

  validates :maintainer_email_address, email_format: true, if: 'maintainer_email_address.present?'
  validates :translation_engine, presence: true, inclusion: { in: %w[bing yandex google] }, if: 'auto_translate'
  validates :secret_token, presence: true
  validates :title, length: { maximum: 25 }
  validates :supported_languages, presence: true
  validates :password, length: { minimum: 5 }, if: :password
  validates :password, confirmation: true, if: :password
  validate :secret_token_unique, if: :secret_token_changed
  validate :public_token_unique, if: 'public_token.present? && public_token_changed'

  # VALIDATIONS
  def secret_token_changed
    secret_token_changed?
  end

  def public_token_changed
    public_token_changed?
  end

  def secret_token_unique
    if Map.all.map(&:secret_token).include? secret_token
      errors.add(:secret_token, I18n.t('.secret_token_not_uniqe'))
    end
  end

  def public_token_unique
    if Map.all.map(&:public_token).include? public_token
      errors.add(:public_token, I18n.t('.public_token_not_unique'))
    end
  end

  # CLASS METHODS
  scope :guest_maps, -> { Map.where(user: nil) }

  # AUTHENTICATION
  def authenticated?(attribute:, token:)
    return false unless digest = self.send("#{attribute}_digest")
    BCrypt::Password.new(digest).is_password?(token)
  end

  def create_digest_for(attribute:)
    token = SecureRandom.urlsafe_base64(24)
    cost = Rails.env == "production" ? BCrypt::Engine::MAX_SALT_LENGTH : 4
    digest = BCrypt::Password.create(token, cost: cost)

    self.send("#{attribute}_digest=", digest)
  end

  def password_protected?
    password_digest.present?
  end

  # INSTANCE METHODS
  def guest_map?
    user.nil?
  end

  def days_left_till_destruction
    if Admin::Setting.auto_destroy_expired_maps?
      days_since_last_visit = last_visit ? (Date.today - last_visit).to_i : 0
      days_left = Admin::Setting.expiry_days - days_since_last_visit
      days_left >= 0 ? days_left : 0
    end
  end

  # HELPER FUNCTIONS
  def reviewed_places?
    places.pluck(:reviewed).any?
  end

  def reviewed_events?
    places.pluck(:reviewed, :event).include?([true, true])
  end

  def all_places
    places.reject(&:event)
  end

  def all_events
    places.select(&:event)
  end

  def all_events_date_range
    min_start_date = places.pluck(:start_date).compact.sort.first
    max_end_date = places.pluck(:end_date).compact.sort.last

    min = min_start_date || Time.now
    max = max_end_date || (min_start_date&.+ 1.year) || (Time.now + 10.year)

    [min, max].join(',')
  end

  def reviewed_events
    all_events.map(&:reviewed_version).compact
  end

  def reviewed_places
    all_places.map(&:reviewed_version).compact
  end

  def unreviewed_places
    unreviewed_places = all_places.reject(&:reviewed)
    places_to_review = unreviewed_places.map do |p|
      p.reviewed_version || p.unreviewed_version
    end
    places_to_review.sort_by(&:updated_at).reverse
  end

  def unreviewed_events
    unreviewed_events = all_events.reject(&:reviewed)
    places_to_review = unreviewed_events.map do |p|
      p.reviewed_version || p.unreviewed_version
    end
    places_to_review.sort_by(&:updated_at).reverse
  end

  def all_translations
    places.all.map { |p| p.translations.to_a }.flatten
  end

  def unreviewed_translations
    all_translations.select { |t| !t.reviewed }
  end

  def id_for_category_string(category_string)
    category = Category.all.find do |cat|
      category_string.tr('_', ' ').casecmp(cat.name).zero?
    end
    category.id if category
  end

  def is_restricted?
    is_public? && !allow_guest_commits
  end

  def is_private?
    !is_public?
  end

  def owner
    user
  end

  def owned_by?(user:)
    user.registered? && owner&.id == user.id 
  end

  def supported_languages_string
    supported_languages.sort.map { |l| I18n.t("languages.#{l}") }.join(', ')
  end

  def category_names
    categories.sort_by(&:name).map(&:name)
  end

  private

  def sanitize_imprint
    self.imprint = sanitize(imprint)
  end

  def sanitize_description
    self.description = sanitize(description)
  end

  TILE_POSITION = {
    z: 16,
    y: 25541,
    x: 18877
  }

  TILE_LAYERS = {
    'ESRI World Imagery' => {
      url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
      image_url: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/#{TILE_POSITION[:z]}/#{TILE_POSITION[:y]}/#{TILE_POSITION[:x]}"
    },
    'ESRI Topo' => {
      url: 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
      attribution: 'Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community',
      image_url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/#{TILE_POSITION[:z]}/#{TILE_POSITION[:y]}/#{TILE_POSITION[:x]}"
    },
    'ESRI Grey' => {
      url: 'http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}',
      attribution: 'Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ',
      image_url: "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/#{TILE_POSITION[:z]}/#{TILE_POSITION[:y]}/#{TILE_POSITION[:x]}"
    }
  }.freeze
end
