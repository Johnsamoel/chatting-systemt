class UpdateChatJob
    include Sidekiq::Job
  
    MAX_RETRIES = 3  # Define your maximum retry count
  
    sidekiq_options retry: MAX_RETRIES
  
    sidekiq_retries_exhausted do |msg|
      Rails.logger.error("Job failed after all retries: #{msg['class']}")
    end
  
    def perform(chat_params)
      retry_count = 0
  
      begin
        raise ArgumentError, 'Missing chat_id or token' unless chat_params['chat_number'] && chat_params['app_number']
  
        chat = Chat.find_by!(id: chat_params['chat_number'], application_id: chat_params['app_number'])
        
        if(!chat)
        raise UpdateFailedError, 'Chat update failed'
        end
        # Update the chat in the database with optimistic locking
        updated_chat = chat.update_with_optimistic_lock(
          chat_name: chat_params['name']
        )
  
        unless updated_chat
          # If the update fails, raise a custom exception
          raise UpdateFailedError, 'Chat update failed.'
        end
  
        Rails.logger.info("Chat updated successfully: #{chat.id}")
   
  
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Chat not found: #{e.message}")
        raise 
        
      rescue ActiveRecord::StaleObjectError => e
        if retry_count < MAX_RETRIES
          Rails.logger.error("Optimistic locking error. Retrying... Attempt #{retry_count + 1}")
          retry_count += 1
          retry
        else
          Rails.logger.error("Optimistic locking error after #{MAX_RETRIES} attempts. Notify the user to try again later.")
          
          raise UpdateFailedError, 'Chat update failed, try again later.'
        end
  
      rescue ArgumentError => e
        Rails.logger.error("Invalid arguments: #{e.message}")
        raise 
      rescue StandardError => e
        Rails.logger.error("Error updating chat: #{e.message}")
        raise 
      end
    
    end
  
    class UpdateFailedError < StandardError; end
  end
  