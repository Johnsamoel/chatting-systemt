# app/controllers/messages_controller.rb

class MessagesController < ActionController::API
  
  before_action :validate_create_message, only: [:create]
  before_action :validate_Search, only: [:search]
  before_action :validate_update_message, only: [:update]

  def create
    CreateMessageJob.perform_sync({
      'body'=> @message_body,
     'application_id' => @found_application.id,
      'chat_id' => @chat.id,
    })

    redis = Redis.new
    message_number = redis.get("latest_message_number")

    if message_number
      render json: { chat_number: message_number }
    else
      render json: { error: "Message wasn't created" }, status: :bad_request
    end
   
  end

  def search
    @chat = Chat.find_by(application_id: @found_application.id, chat_number: @chat_id)
  
    page_number = @page_number.to_i
    # Perform Elasticsearch search
    @messages = Message.search(@message_body, page: @page_number.to_i)
  
    if @messages
      render json: @messages
    else
      render json: { error: "Invalid search query" }, status: :not_found
    end
  end

  def update
    if @message_body.nil?
      render json: { error: "Invalid message body" }, status: :bad_request
    else
      begin
        updated_Message_status = UpdateMessageJob.perform_sync({
          'body' => @message_body,
          'message_number' => @message.id,
          'chat_number' => @chat.id, 
        })
  
        if updated_Message_status
          render json: { message: "Message was updated successfully" }
        else
          render json: { error: "Something went wrong during the update. Please try again." }, status: :unprocessable_entity
        end
      
      rescue UpdateMessageJob::UpdateFailedError => e
        render json: { error: "Message update failed. Please try again later." }, status: :unprocessable_entity
      end
    
    end
  end
  
  
  
  private

  def messages_params
    params.permit(:message , :chat_id , :token )
  end

  def validate_Search
    token = params[:token]
    @message_body = params[:message]
    @chat_id = params[:chat_id]
    @page_number = params[:page]

    validate_token(token)
    find_chat(@chat_id)
  end

  def validate_update_message
    token = params[:token]
    @message_id = params[:message_number]
    @chat_id = params[:chat_id]
    @message_body = params[:body]

    validate_token(token)
    find_chat(@chat_id)
    find_message(@message_id)
  end

  def validate_create_message
    token = params[:token]
    @message_id = params[:message_id]
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

  def find_message(message_id)
    @message = Message.find(@message_id) if @message_id
    if !@message
      render json: {error: "Invalid token or Message number"} ,status: :not_found
    end
  end

end
