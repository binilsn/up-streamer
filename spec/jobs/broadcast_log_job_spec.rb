require "rails_helper"

RSpec.describe BroadcastLogJob, type: :job do
  let!(:service) { create(:service) }
  let!(:log) { create(:log, service: service) }

  let(:expected_payload) do
    {
      id: log.id,
      timestamp: log.timestamp.iso8601(3),
      level: log.level,
      service: log.service.name,
      message: log.message,
      hostname: log.hostname,
      error_code: log.error_code,
      metadata: log.metadata
    }
  end

  describe "#perform" do
    it "broadcasts to live_stream with the correct payload" do
      allow(ActionCable.server).to receive(:broadcast)
      described_class.perform_now(log.id)
      expect(ActionCable.server).to have_received(:broadcast).with("live_stream", expected_payload)
    end

    it "does not broadcast when the log is missing" do
      allow(ActionCable.server).to receive(:broadcast)
      described_class.perform_now(-1)
      expect(ActionCable.server).not_to have_received(:broadcast)
    end

    it "does not raise when the log is missing" do
      expect { described_class.perform_now(-1) }.not_to raise_error
    end
  end
end
