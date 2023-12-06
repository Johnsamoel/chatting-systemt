class ChatsController < ActionController::API
  require 'jwt'
  before_action :validate_token_and_find_application, only: [:create]

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

  private

  def chat_params
    params.require(:chat).permit(:name, :token) 
  end

  # Validates the token and finds the app
  def validate_token_and_find_application
    token = params.dig(:chat, :token) || params[:token]
    @found_application = Application.find_by_token(token)
    
    unless @found_application
      render json: { error: "Application not found or invalid token" }, status: :not_found
    end
  end
end
