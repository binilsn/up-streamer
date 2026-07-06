require "rails_helper"

RSpec.describe Log, type: :model do
  describe "validations" do
    it "requires a message" do
      log = build(:log, message: nil)
      expect(log).not_to be_valid
      expect(log.errors[:message]).to include("can't be blank")
    end

    it "requires a timestamp" do
      log = build(:log, timestamp: nil)
      expect(log).not_to be_valid
      expect(log.errors[:timestamp]).to include("can't be blank")
    end

    it "raises on invalid level" do
      expect { build(:log, level: "invalid") }.to raise_error(ArgumentError, /'invalid' is not a valid level/)
    end
  end

  describe "associations" do
    it "belongs to a service" do
      log = create(:log)
      expect(log.service).to be_present
    end
  end

  describe "scopes" do
    let!(:service) { create(:service) }
    let!(:error_log) { create(:log, service: service, level: "error", timestamp: 1.minute.ago) }
    let!(:info_log) { create(:log, service: service, level: "info", timestamp: 2.minutes.ago) }

    it "filters by level" do
      expect(Log.by_level("error")).to contain_exactly(error_log)
    end

    it "orders by timestamp descending" do
      expect(Log.recent.first).to eq(error_log)
    end

    it "searches by message" do
      expect(Log.search_message(error_log.message)).to contain_exactly(error_log)
    end
  end
end
