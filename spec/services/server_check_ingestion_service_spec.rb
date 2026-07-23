require "rails_helper"

RSpec.describe ServerCheckIngestionService do
  describe "#call" do
    let!(:service) { create(:service) }

    context "when the token is valid" do
      let(:params) do
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

      it "is successful" do
        result = described_class.new(token: service.access_token, params: params).call
        expect(result).to be_success
      end

      it "persists the server check" do
        result = described_class.new(token: service.access_token, params: params).call
        expect(result.server_check).to be_persisted
      end

      it "sets the correct status" do
        result = described_class.new(token: service.access_token, params: params).call
        expect(result.server_check.status).to eq("up")
      end

      it "sets the correct response time" do
        result = described_class.new(token: service.access_token, params: params).call
        expect(result.server_check.response_time_ms).to eq(42)
      end
    end

    context "when the token is invalid" do
      it "returns unauthorized" do
        result = described_class.new(token: "invalid-token", params: { status: "up" }).call
        expect(result).not_to be_success
      end

      it "includes unauthorized error" do
        result = described_class.new(token: "invalid-token", params: { status: "up" }).call
        expect(result.errors).to include("unauthorized")
      end
    end

    context "when the params are invalid" do
      it "returns unsuccessful" do
        result = described_class.new(token: service.access_token, params: { status: "up", checked_at: nil }).call
        expect(result).not_to be_success
      end

      it "includes error messages" do
        result = described_class.new(token: service.access_token, params: { status: "up", checked_at: nil }).call
        expect(result.errors).to be_any
      end
    end
  end
end
