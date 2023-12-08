class CreateMessageJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    Rails.logger.error("Job failed after all retries: #{msg['class']}")
  end


  def perform(message_params)
    begin

      new_message = Message.create!(body: message_params['body'], chat_id: (message_params['chat_id'] + 1))
    
      store_Message_id_in_redis(new_message.id)
    rescue StandardError => e
      # Log the error or handle it appropriately
      Rails.logger.error("Error creating Message: #{e.message}")
      raise
    end
  end
  
  


  def store_Message_id_in_redis(message_id)

    redis = Redis.new
    redis.set("latest_message_number", message_id)
  end

end
