class AlertsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "alerts"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
