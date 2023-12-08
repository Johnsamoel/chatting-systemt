class CreateChatJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    Rails.logger.error("Job failed after all retries: #{msg['class']}")
  end


  def perform(chat_params)
    begin
      newChat = Chat.create!(chat_params)
  
    rescue StandardError => e
      # Log the error or handle it appropriately
      Rails.logger.error("Error creating chat: #{e.message}")
      raise
    end
  end

end
