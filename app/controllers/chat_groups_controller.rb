class ChatGroupsController < ActionController::API
  require 'jwt'
  before_action :validate_token_and_find_application, only: [:find_application]

  def create
    find_app = Application.find_by(name: application_params[:name])

    if find_app
      render json: { message: "Choose a different Name" }, status: :conflict
    else
      @application = Application.new(application_params)
      @application.token = generate_jwt_token

      if @application.save
        render json: { token: @application.token, name: @application.name, id: @application.id }, status: :created
      else
        render json: { error: @application.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end


  def find_application
    render json: { application: @found_application }
  end

  private
  def application_params
    params.permit(:name, :token)
  end


  # Helper method to create application token
  def generate_jwt_token
    payload = { application_id: @application.id, name: @application.name }
    JWT.encode(payload, ENV['TOKEN_SECRET'], 'HS256')
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
