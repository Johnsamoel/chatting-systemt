class CreateChatJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    Rails.logger.error("Job failed after all retries: #{msg['class']}")
  end


  def perform(chat_params)
    begin
      new_chat = Chat.create!(chat_params)

      # Store the created chat ID in Redis
      store_chat_id_in_redis(new_chat.id)

    rescue StandardError => e
      # Log the error or handle it appropriately
      Rails.logger.error("Error creating chat: #{e.message}")
      raise
    end
  end

  private

  def store_chat_id_in_redis(chat_id)
    redis = Redis.new
    redis.set("lastest_chat_number", chat_id)
  end

end
