# app/controllers/chats_controller.rb

class ChatsController < ActionController::API
  require 'jwt'
  before_action :validate_create, only: [:create]
  before_action :validate_update, only: [:update]
  before_action :validate_get_messages, only: [:get_messages]

  def create
    created_name = params.dig(:chat, :name)
    @chat = Chat.new(chat_name: created_name, application_id: @found_application.id)

    if @chat.save
      @found_application.increment!(:chats_count)
      render json: { chat_number: @chat.id }
    else
      render json: { error: "Failed to create chat", errors: @chat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    updated_chat = @chat.update({chat_name: @chat_name})
    if updated_chat
      render json: { message: "Chat updated successfully" }
    else
      render json: { error: "Failed to update chat", errors: @chat.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def get_messages
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    messages = @chat.messages.paginate(page: page, per_page: per_page)

    render json: { messages: messages }
  end

  private

  def chat_params
    params.require(:chat).permit(:name)
  end


  def validate_get_messages
    token = params[:token]
    @chat_id = params[:chat_id]
    validate_token(token)
    @chat = Chat.find(@chat_id) if @chat_id
    if !@chat
      render json: {error: "Invalid token or chat id"} ,status: :not_found
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
        render json: { error: "Application not found or invalid token" }, status: :not_found
      end
    end
end
