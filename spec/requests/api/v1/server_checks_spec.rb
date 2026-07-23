require "rails_helper"

RSpec.describe "Api::V1::ServerChecks", type: :request do
  let!(:service) { create(:service) }
  let(:headers) { { "Authorization" => "Bearer #{service.access_token}", "Content-Type" => "application/json" } }

  describe "POST /api/v1/server_checks" do
    let(:valid_params) do
      {
        status: "up",
        response_time_ms: 42,
        ssl_valid: true,
        ssl_expires_at: 90.days.from_now.iso8601,
        ssl_issuer: "Let's Encrypt",
        checked_at: Time.current.iso8601,
        metadata: { region: "us-east-1" }
      }
    end

    context "with valid token" do
      it "creates a server check" do
        expect {
          post api_v1_server_checks_path, params: valid_params.to_json, headers: headers
        }.to change(ServerCheck, :count).by(1)
      end

      it "returns 201 created" do
        post api_v1_server_checks_path, params: valid_params.to_json, headers: headers
        expect(response).to have_http_status(:created)
      end

      it "returns the check id" do
        post api_v1_server_checks_path, params: valid_params.to_json, headers: headers
        expect(response.parsed_body).to have_key("id")
      end
    end

    context "with invalid token" do
      it "returns 401 unauthorized" do
        post api_v1_server_checks_path, params: valid_params.to_json, headers: { "Authorization" => "Bearer bad-token" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid params" do
      it "returns 422 unprocessable content" do
        post api_v1_server_checks_path, params: { status: "up", checked_at: nil }.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /api/v1/server_checks" do
    it "returns 200 ok" do
      create(:server_check, service: service, checked_at: 1.hour.ago)
      get api_v1_server_checks_path, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "returns a data array" do
      create(:server_check, service: service, checked_at: 1.hour.ago)
      get api_v1_server_checks_path, headers: headers
      expect(response.parsed_body["data"]).to be_an(Array)
    end
  end
end
