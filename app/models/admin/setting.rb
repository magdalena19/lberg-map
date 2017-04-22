require 'validators/custom_validators'

class Admin::Setting < ActiveRecord::Base
  include CustomValidators

  validates :app_title, length: { maximum: 20 }
  validates :admin_email_address, presence: true, email_format: true
  validates :user_activation_tokens, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.all_settings
    self.last.attributes.except("id")
  end

  def self.translation_engines
    %w[google bing yandex]
  end

  Admin::Setting.create unless Admin::Setting.any?
  # spawn default values (-> schema) if no current settings available
  attributes = column_names.reject { |x| x == 'id' }
  attributes.each do |attribute|
    define_singleton_method(attribute.to_sym) do
      last.send(attribute)
    end
  end
end
