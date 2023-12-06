class ChatsController < ActionController::API
  require 'jwt'
  before_action :validate_token_and_find_application, only: [:create]

  def create
    @chat = @found_application.chats.create(application_id: @found_application.id)
    @found_application.increment!(:chats_count)
    render json: { chat_number: @chat.number }
  end

  private

  def application_params
    params.permit(:name, :token)
  end

  # Validates the token and finds the app
  def validate_token_and_find_application
    token = params[:token]
    @found_application = Application.find_by_token(token)
    if @found_application.blank?
      render json: { error: "Application not found or invalid token" }, status: :not_found
    end
  end
end
