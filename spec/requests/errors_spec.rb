require 'rails_helper'

RSpec.describe "Errors", type: :request do
  describe "GET /not_found" do
    it 'returns a not found response' do
      get '/not_found'
      
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to eq('application/json; charset=utf-8')

      body = JSON.parse(response.body)
      expect(body).to include('error' => 'Route not found')
    end
  end

  it 'handles unknown routes' do
    get '/unknown_route'

    expect(response).to have_http_status(:not_found)
    expect(response.content_type).to eq('application/json; charset=utf-8')

    body = JSON.parse(response.body)
    expect(body).to include('error' => 'Route not found')
  end
end
