require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.storage = :file
  config.enable_processing = Rails.env.test? ? false : true
end
