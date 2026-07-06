require "rails_helper"

RSpec.describe LogIngestionService do
  describe "#call" do
    let!(:service) { create(:service) }

    context "when the token is valid" do
      let(:log_params) do
        {
          level: "error",
          message: "Connection timeout",
          hostname: "prod-01",
          error_code: "TIMEOUT_500",
          timestamp: Time.current.iso8601,
          metadata: { region: "us-east-1" }
        }
      end

      it "is successful" do
        result = described_class.new(token: service.access_token, log_params: log_params).call
        expect(result).to be_success
      end

      it "persists the log" do
        result = described_class.new(token: service.access_token, log_params: log_params).call
        expect(result.log).to be_persisted
      end

      it "sets the correct message" do
        result = described_class.new(token: service.access_token, log_params: log_params).call
        expect(result.log.message).to eq("Connection timeout")
      end

      it "sets the correct level" do
        result = described_class.new(token: service.access_token, log_params: log_params).call
        expect(result.log.level).to eq("error")
      end

      it "enqueues BroadcastLogJob" do
        expect {
          described_class.new(token: service.access_token, log_params: log_params).call
        }.to have_enqueued_job(BroadcastLogJob)
      end
    end

    context "when the token is invalid" do
      it "returns unauthorized" do
        result = described_class.new(token: "invalid-token", log_params: { message: "test" }).call
        expect(result).not_to be_success
      end

      it "includes unauthorized error" do
        result = described_class.new(token: "invalid-token", log_params: { message: "test" }).call
        expect(result.errors).to include("unauthorized")
      end
    end

    context "when the log params are invalid" do
      it "returns validation errors" do
        result = described_class.new(token: service.access_token, log_params: { message: nil }).call
        expect(result).not_to be_success
      end

      it "includes message error" do
        result = described_class.new(token: service.access_token, log_params: { message: nil }).call
        expect(result.errors).to include("Message can't be blank")
      end
    end
  end
end
