require 'validators/custom_validators'
require 'sanitize'

class Map < ActiveRecord::Base
  include CustomValidators
  include Sanitization

  has_many :places
  has_many :categories
  has_many :announcements
  has_many :messages
  belongs_to :user

  before_validation :sanitize_description
  before_validation :sanitize_imprint

  validates :maintainer_email_address, email_format: true, if: 'maintainer_email_address.present?'
  validates :translation_engine, presence: true, inclusion: { in: %w[bing yandex google] }, if: 'auto_translate'
  validates :secret_token, presence: true
  validate :secret_token_unique
  validate :public_token_unique, if: 'public_token.present?'

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

  private

  def sanitize_imprint
    self.imprint = sanitize(imprint)
  end

  def sanitize_description
    self.description = sanitize(description)
  end
end
