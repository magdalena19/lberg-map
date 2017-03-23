require 'validators/custom_validators'

class Map < ActiveRecord::Base
  include CustomValidators

  has_many :places
  has_many :categories
  has_many :announcements
  has_many :messages

  # TODO abandon this
  before_create :generate_secret_token
  before_create :generate_public_token, if: 'is_public'

  validates :maintainer_email_address, email_format: true, if: 'maintainer_email_address.present?'
  validates :translation_engine, presence: true, inclusion: { in: %w[bing yandex google] }, if: 'auto_translate'

  def reviewed_places
    places.all.map(&:reviewed_version).compact
  end

  def unreviewed_places
    unreviewed_places = places.all.find_all(&:unreviewed_version)
    places_to_review = unreviewed_places.map do |p|
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

  def category_names_list
    categories.all.map(&:name).join(', ')
  end

  def id_for_categorey_string(category_string)
    category = Category.all.find do |cat|
      category_string.tr('_', ' ').casecmp(cat.name).zero?
    end
    category.id if category
  end

  private

  # TODO is Käse, muss via Formular gemacht werden
  # Muss im form field für maps gesetzt werden, sofern noch nicht vorhanden (value: @map.public_token ? @map.public_token : SecureRandom...)
  def generate_public_token
    self.public_token = SecureRandom.urlsafe_base64(24)
  end

  # TODO is Käse, muss via Formular gemacht werden
  # Muss im form field für maps gesetzt werden, sofern noch nicht vorhanden (value: @map.public_token ? @map.public_token : SecureRandom...)
  def generate_secret_token
    self.secret_token = SecureRandom.urlsafe_base64(24)
  end
end
