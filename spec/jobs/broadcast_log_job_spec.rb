require "rails_helper"

RSpec.describe BroadcastLogJob, type: :job do
  let!(:service) { create(:service) }
  let!(:log) { create(:log, service: service) }

  describe "#perform" do
    it "broadcasts the log data to the live_stream channel" do
      expected_payload = {
        id: log.id,
        timestamp: log.timestamp.iso8601(3),
        level: log.level,
        service: log.service.name,
        message: log.message,
        hostname: log.hostname,
        error_code: log.error_code,
        metadata: log.metadata
      }

      expect(ActionCable.server).to receive(:broadcast).with("live_stream", expected_payload)
      BroadcastLogJob.perform_now(log.id)
    end

    it "handles a missing log gracefully" do
      expect(ActionCable.server).not_to receive(:broadcast)
      expect { BroadcastLogJob.perform_now(-1) }.not_to raise_error
    end
  end
end
