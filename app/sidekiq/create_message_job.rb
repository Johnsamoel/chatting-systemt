class CreateMessageJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    Rails.logger.error("Job failed after all retries: #{msg['class']}")
  end


  def perform(message_params)
    begin
      @chat = Chat.find_by(application_id: message_params['application_id'], number: message_params['chat_number'])
      new_message = Message.create!(body: message_params['body'], chat: @chat)
  
    rescue StandardError => e
      # Log the error or handle it appropriately
      Rails.logger.error("Error creating Message: #{e.message}")
      raise
    end
  end

end
