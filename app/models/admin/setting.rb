require 'validators/custom_validators'
require 'auto_translation/auto_translate'
require 'sanitize'

class Admin::Setting < ActiveRecord::Base
  include CustomValidators
  include Sanitization

  after_validation :sanitize_app_privacy_policy, on: [:create, :update]
  after_validation :sanitize_app_imprint, on: [:create, :update]

  validates :app_title, length: { maximum: 20 }
  validates :admin_email_address, presence: true, email_format: true
  validates :user_activation_tokens, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :captcha_system, inclusion: { in: %w[recaptcha simple_captcha] }
  validates :default_poi_color, inclusion: { in: Place.available_colors }

  ## SANITIZE
  def sanitize_app_imprint
    self.app_imprint = sanitize(app_imprint)
  end

  def sanitize_app_privacy_policy
    self.app_privacy_policy = sanitize(app_privacy_policy)
  end

  def self.all_settings
    self.last.attributes.except("id")
  end

  def self.working_translation_engines
    engines = self.translation_engines.select do |engine|
      AutoTranslate::Helpers.translation_engine_working?(engine: engine)
    end
    engines.unshift 'none'
  end

  def self.captcha_systems
    %w[recaptcha simple_captcha]
  end

  def self.auto_destroy_expired_maps?
    expiry_days > 0
  end

  Admin::Setting.create unless Admin::Setting.any?
  # spawn default values (-> schema) if no current settings available
  attributes = column_names.reject { |x| x == 'id' }
  attributes.each do |attribute|
    define_singleton_method(attribute.to_sym) do
      last.send(attribute)
    end
  end

  private

  def self.translation_engines
    %w[google bing yandex]
  end
end
