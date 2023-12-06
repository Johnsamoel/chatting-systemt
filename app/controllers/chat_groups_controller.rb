class ChatGroupsController < ActionController::API
  require 'jwt'
  before_action :validate_token_and_find_application, only: [:find_application, :update, :get_chats ]

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

  def update
    updated_app = @found_application.update(name: application_params[:name])

    if updated_app
      render json: { message: "Application was updated successfully", application: updated_app }
    else
      render json: { error: "Something went wrong. Your application failed to update." }
    end
  end

  def find_applications
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    applications = Application.paginate(page: page, per_page: per_page)

    if applications
      render json: { applications: applications }
    else
      render json: {error: "something went wrong"} , status: :not_found
    end
  end
  
  def get_chats
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    chats = @found_application.chats.paginate(page: page, per_page: per_page)

    if chats
      render json: { chats: chats }
    else
      render json: {error: "something went wrong"} , status: :not_found
    end
  
  end

  def find_application
    render json: { application: @found_application }
  end

  private

  def application_params
    params.permit(:name, :token, :page)
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
