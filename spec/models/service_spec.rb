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
    it "filters active services" do
      active = create(:service, active: true)
      inactive = create(:service, active: false)
      expect(Service.active).to include(active)
      expect(Service.active).not_to include(inactive)
    end
  end
end
