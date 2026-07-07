require "rails_helper"

RSpec.describe Service, type: :model do
  describe "associations" do
    it "has many logs" do
      service = create(:service)
      log = create(:log, service: service)
      expect(service.logs).to include(log)
    end
  end

  describe "scopes" do
    it "returns active services" do
      active = create(:service, active: true, name: "test-active-#{SecureRandom.hex(4)}")
      expect(described_class.active).to include(active)
    end

    it "excludes inactive services" do
      inactive = create(:service, active: false, name: "test-inactive-#{SecureRandom.hex(4)}")
      expect(described_class.active).not_to include(inactive)
    end
  end
end
