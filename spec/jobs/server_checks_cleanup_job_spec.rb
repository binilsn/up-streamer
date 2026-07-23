require "rails_helper"

RSpec.describe ServerChecksCleanupJob, type: :job do
  describe "#perform" do
    let!(:service) { create(:service) }

    it "deletes server checks older than 7 days" do
      create(:server_check, service: service, checked_at: 8.days.ago)
      expect {
        described_class.perform_now
      }.to change(ServerCheck, :count).by(-1)
    end

    it "keeps server checks newer than 7 days" do
      create(:server_check, service: service, checked_at: 1.day.ago)
      expect {
        described_class.perform_now
      }.not_to change(ServerCheck, :count)
    end
  end
end
