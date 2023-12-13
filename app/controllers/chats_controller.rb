# app/controllers/chats_controller.rb

class ChatsController < ActionController::API
  require 'jwt'
  before_action :validate_create, only: [:create]
  before_action :validate_update, only: [:update]
  # before_action :validate_get_messages, only: [:get_messages]



  def create
    begin
      created_name = params.dig(:chat, :name)
      validate_create # Validate and set variables

      CreateChatJob.perform_sync({ 'chat_name' => created_name, 'application_id' => @found_application.id })

      redis = Redis.new
      chat_number = redis.get("lastest_chat_number")

      if chat_number
        render json: { chat_number: chat_number }
      else
        render json: { error: "Chat wasn't created" }, status: :bad_request
      end
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end

  def update
    begin

      update_chat_job = UpdateChatJob.perform_sync({
        'name' => @chat_name,
        'app_number' => @found_application.id,
        'chat_number' => @chat_id
      })

      if update_chat_job
        render json: { message: "Chat updated successfully" }
      else
        render json: { error: "Failed to update chat", errors: @chat.errors.full_messages }, status: :unprocessable_entity
      end
    rescue UpdateMessageJob::UpdateFailedError => e
      render json: { error: "Chat update failed. Please try again later: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end

  def get_messages
    begin
      validate_get_messages

      if !@chat
        render json: { error: "Invalid token or chat id" }, status: :not_found
        return
      end

      @page = params[:page].to_i
    
      if !@page || @page <= 0
        render json: { error: "Invalid parameter", field: "page_number" }, status: :bad_request
        return
      end

      per_page = params[:per_page] || 10
  
      if @chat
        messages = @chat.messages.paginate(page: @page, per_page: per_page) || []
        render json: { messages: messages }
      else
        render json: { error: "Chat not found" }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end
  
  private

    def chat_params
      params.require(:chat).permit(:name , :token)
    end


    def validate_get_messages
      token = params[:token]
      @chat_id = params[:chat_id]
      validate_token(token)
      
      if @chat_id.present?
        @chat = @found_application.chats.find_by(id: @chat_id)
      end
    
    end
    

    def validate_update
      token = params.dig(:chat, :token)
      @chat_name = params.dig(:chat, :name)
      @chat_id = params[:id]
      validate_token(token)
      @chat = Chat.find(params[:id]) if params[:id]
      if !@chat
        render json: {error: "Invalid token or chat id"} ,status: :not_found
      end
    end

    # Validates
    def validate_create
      token = params.dig(:chat, :token) || params[:token]
      validate_token(token)
    end

    def validate_token(token)
      @found_application = Application.find_by_token(token)
      
      unless @found_application
        render json: { error: "Application not found or invalid token" }, status: :bad_request
      end
    end
end
