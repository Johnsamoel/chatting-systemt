# app/controllers/messages_controller.rb

class MessagesController < ActionController::API
  
  before_action :validate_create_message, only: [:create]
  # before_action :validate_find_message, only: [:find_message]

  def create
    CreateMessageJob.perform_async({
      'body'=> @message_body,
     'number'=> (@chat.messages_count || 0) ,
     'application_id' => params[:application_id],
      'number' => params[:chat_number] 
    })

    render json: {message: "Message creation started"}
  end

  # def find_message
  #   @chat = Chat.find_by(application_id: @found_application.id, chat_number: @chat_id)

  #   # Perform Elasticsearch search
  #   @messages = Message.search("just")

  #   render json: @messages
  # end

  private

  def messages_params
    params.permit(:message , :chat_id , :token )
  end

  def validate_find_message
    token = params[:token]
    @message_body = params[:message]
    @chat_id = params[:chat_id]

    validate_token(token)
    find_chat(@chat_id)
  end

  def validate_create_message
    token = params[:token]
    @message_body = params[:message]
    @chat_id = params[:chat_id]

    validate_token(token)
    find_chat(@chat_id)
  end

  def validate_token(token)
    @found_application = Application.find_by_token(token)
    render_error("Application not found or invalid token", :not_found) unless @found_application
  end

  def find_chat(chat_id)
    @chat = Chat.find_by(id: chat_id)
    render_error("Invalid token or chat id", :not_found) unless @chat
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end

end
