require "rails_helper"

RSpec.describe ServerCheck, type: :model do
  describe "associations" do
    it "belongs to a service" do
      check = create(:server_check)
      expect(check.service).to be_present
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      check = build(:server_check)
      expect(check).to be_valid
    end

    it "requires status" do
      check = build(:server_check, status: nil)
      expect(check).not_to be_valid
    end

    it "requires a valid status" do
      expect { build(:server_check, status: "invalid") }.to raise_error(ArgumentError)
    end

    it "requires checked_at" do
      check = build(:server_check, checked_at: nil)
      expect(check).not_to be_valid
    end

    it "validates response_time_ms is non-negative" do
      check = build(:server_check, response_time_ms: -1)
      expect(check).not_to be_valid
    end

    it "allows nil response_time_ms" do
      check = build(:server_check, response_time_ms: nil)
      expect(check).to be_valid
    end
  end

  describe "scopes" do
    let!(:service) { create(:service) }

    it "returns recent checks ordered by checked_at desc" do
      old = create(:server_check, service: service, checked_at: 2.hours.ago)
      recent = create(:server_check, service: service, checked_at: 1.minute.ago)
      expect(described_class.recent.first).to eq(recent)
    end

    it "includes checks older than 7 days" do
      stale = create(:server_check, service: service, checked_at: 8.days.ago)
      expect(described_class.stale).to include(stale)
    end

    it "excludes fresh checks" do
      fresh = create(:server_check, service: service, checked_at: 1.day.ago)
      expect(described_class.stale).not_to include(fresh)
    end
  end

  describe "enums" do
    it "defines up/down/degraded statuses" do
      expect(described_class.statuses.keys).to match_array(%w[up down degraded])
    end
  end
end
