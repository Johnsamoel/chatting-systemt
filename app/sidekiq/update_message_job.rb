class UpdateMessageJob
  include Sidekiq::Job

  MAX_RETRIES = 2  # Define your maximum retry count

  sidekiq_options retry: MAX_RETRIES

  sidekiq_retries_exhausted do |msg|
    Rails.logger.error("Job failed after all retries: #{msg['class']}")
  end

  def perform(message_params)
    retry_count = 0

    begin
      raise ArgumentError, 'Missing message_number or chat_number' unless message_params['message_number'] && message_params['chat_number']

      message = Message.find_by!(id: message_params['message_number'], chat_id: message_params['chat_number'])
      
      # Update the message in the database with optimistic locking
      updated_message = message.update_with_optimistic_lock(
        body: message_params['body']
      )

      unless updated_message
        # If the update fails, raise a custom exception
        raise UpdateFailedError, 'Message update failed.'
      end

      Rails.logger.info("Message updated successfully: #{message.id}")

      new_message = Message.find_by!(id: message_params['message_number'], chat_id: message_params['chat_number'])

      # Update Elasticsearch index
      new_message.__elasticsearch__.update_document
      Rails.logger.info("Elasticsearch index updated successfully.")

    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Message not found: #{e.message}")
      raise # Re-raise the exception so that it's logged and potentially handled in a higher layer
      
    rescue ActiveRecord::StaleObjectError => e
      if retry_count < MAX_RETRIES
        Rails.logger.error("Optimistic locking error. Retrying... Attempt #{retry_count + 1}")
        retry_count += 1
        retry
      else
        Rails.logger.error("Optimistic locking error after #{MAX_RETRIES} attempts. Notify the user to try again later.")
        # Notify the user to try again later
        raise UpdateFailedError, 'Message update failed, try again later.'
      end

    rescue ArgumentError => e
      Rails.logger.error("Invalid arguments: #{e.message}")
      raise # Re-raise the exception so that it's logged and potentially handled in a higher layer
    rescue StandardError => e
      Rails.logger.error("Error updating message: #{e.message}")
      raise # Re-raise the exception so that it's logged and potentially handled in a higher layer
    end
  
  end

  class UpdateFailedError < StandardError; end
end
