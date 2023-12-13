require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  describe 'POST #create' do
    context 'when creating a chat is successful' do
      let(:valid_attributes) { { chat: { name: 'TestChatName' }, token: 'valid_token' } }

      before do
        setup_valid_create_request
        post :create, params: valid_attributes
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the chat number' do
        expect(JSON.parse(response.body)).to include('chat_number' => 'latest_chat_number')
      end
    end

    context 'when creating a chat is unsuccessful' do
      let(:invalid_attributes) { { chat: { name: 'InvalidChatName' }, token: 'invalid_token' } }

      before do
        setup_invalid_create_request
        post :create, params: invalid_attributes
      end

      it 'returns a bad request response' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)).to include('error' => 'Application not found or invalid token')
      end
    end
  end

  describe 'GET #get_messages' do
  let(:valid_token) { 'valid_token' }
  let(:valid_chat_id) { 1 }
  let(:valid_chat) { instance_double(Chat) }
  let(:valid_messages) { [] }

  before do
    allow(controller).to receive(:render)
    allow(Chat).to receive(:find_by).and_return(valid_chat)
    allow(valid_chat).to receive(:messages).and_return(valid_messages)
  end


  it 'calls validate_get_messages' do
    allow(controller).to receive(:validate_get_messages)
    get :get_messages, params: { token: valid_token, chat_id: valid_chat_id }

    expect(controller).to have_received(:validate_get_messages)
  end


  it 'renders an error message when fetching messages is unsuccessful' do
    allow(controller).to receive(:validate_get_messages).and_raise(StandardError.new('Some error'))
    get :get_messages, params: { token: valid_token, chat_id: valid_chat_id }

    # Adjust the expectation to match the actual response structure
    expect(controller).to have_received(:render).with(json: { error: 'An error occurred while processing your request: Some error' }, status: :internal_server_error)
  end
  end

  # Helper methods for stubbing and setting up requests
  def setup_valid_create_request
    application = instance_double(Application, id: 1)
    allow(Application).to receive(:find_by_token).with('valid_token').and_return(application)

    allow(CreateChatJob).to receive(:perform_sync).and_return(true)

    allow(Redis).to receive(:new).and_return(instance_double(Redis, get: 'latest_chat_number'))
  end

  def setup_invalid_create_request
    allow(Application).to receive(:find_by_token).with('invalid_token').and_return(nil)
  end

  def setup_valid_get_messages_request(chat_id)
    allow(controller).to receive(:validate_get_messages)
    allow(valid_chat).to receive(:messages).and_return(valid_messages)
    allow(Chat).to receive(:find).with(chat_id).and_return(valid_chat)
  end

  def setup_invalid_get_messages_request(_params, error_message)
    allow(controller).to receive(:validate_get_messages).and_raise(StandardError, error_message)
  end
end
