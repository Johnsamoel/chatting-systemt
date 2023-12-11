class ChatGroupsController < ActionController::API
  require 'jwt'
  before_action :validate_token_and_find_application, only: [:find_application, :update, :get_chats]

  def create
    begin
      find_app = Application.find_by(name: application_params[:name])

      if find_app
        render json: { error: "Choose a different Name", field: "name" }, status: :conflict
      else
        @application = Application.new(application_params)
        @application.token = generate_jwt_token

        if @application.save
          render json: { token: @application.token, name: @application.name, id: @application.id }, status: :created
        else
          render json: { error: "Failed to create application", errors: @application.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end

  def update
    begin
      updated_app = @found_application.update(name: application_params[:name])

      if updated_app
        render json: { message: "Application was updated successfully" }
      else
        render json: { error: "Failed to update application", errors: @found_application.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end

  def find_applications
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      applications = Application.paginate(page: page, per_page: per_page)

      if applications.any?
        render json: { applications: applications }
      else
        render json: { error: "No applications found" }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end

  def get_chats
    begin
      page = params[:page] || 1
      per_page = params[:per_page] || 10
  
      chats = @found_application.chats.paginate(page: page, per_page: per_page)
  
      render json: { chats: chats }
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end
  

  def find_application
    begin
      render json: { application: @found_application }
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
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
    begin
      token = params[:token]
      @found_application = Application.find_by_token(token)

      if @found_application.blank?
        render json: { error: "Application not found or invalid token", field: "token" }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: "An error occurred while processing your request: #{e.message}" }, status: :internal_server_error
    end
  end
end
