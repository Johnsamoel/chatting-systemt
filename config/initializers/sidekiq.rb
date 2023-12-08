# Use the Docker container name as the hostname
redis_container_name = 'redis'

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379" }
end
