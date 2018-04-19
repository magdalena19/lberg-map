class Category < ActiveRecord::Base
  belongs_to :map
  has_many :place_category, dependent: :nullify
  has_many :places, through: :place_category

  before_create :prepare_for_translation

  translates :name
  globalize_accessors

  default_scope { order(priority: :asc) }

  # VALIDATIONS
  validates :priority, presence: true
  validates :marker_shape, presence: true
  validates :marker_color, presence: true
  validates :marker_icon_class, presence: true
  validate :any_name_present

  def any_name_present
    translated_names = globalize_attribute_names.map { |name| send(name).present? }

    # Return error unless at least one name present
    unless translated_names.any?
      errors.add(:name, I18n.t('.all_names_empty'))
    end
  end

  # Set all name columns to empty in order to create translation records on create
  def prepare_for_translation
    I18n.available_locales.each do |locale|
      next if send("name_#{locale}").present?
      send("name_#{locale}=", '')
    end
  end

  # Return all globalized attributes for category in a single hash
  def to_json
    attr = [*self.globalize_attribute_names]
    result = attr.map { |a| [a, self.send(a)] }.to_h
    result[:categoryId] = id
    result[:poiCount] = places.count
    result
  end
end
