require "rails_helper"

RSpec.describe LiveStreamChannel, type: :channel do
  describe "#subscribed" do
    it "streams from live_stream" do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("live_stream")
    end
  end
end
