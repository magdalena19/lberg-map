require 'ostruct'

all_config = YAML.load_file("#{Rails.root}/config/app_config.yml") || {}
env_config = all_config[Rails.env] || {}
AppConfig = OpenStruct.new(env_config)
