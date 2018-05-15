sidekiq_config = { url: ENV['SIDEKIQ_REDIS'] }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config#{ url: 'redis://redis:6379/12' }
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config#{ url: 'redis://redis:6379/12' }
end
