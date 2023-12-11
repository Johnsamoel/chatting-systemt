# Use the Docker container name as the hostname
redis_container_name = 'redis'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"]  }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"]  }
end
