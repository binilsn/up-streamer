class LiveStreamChannel < ApplicationCable::Channel
  def subscribed
    stream_from "live_stream"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
