class BroadcastLogJob < ApplicationJob
  queue_as :default

  def perform(log_id)
    log = Log.find_by(id: log_id)
    return unless log

    payload = {
      id: log.id,
      timestamp: log.timestamp.iso8601(3),
      level: log.level,
      service: log.service.name,
      message: log.message,
      hostname: log.hostname,
      error_code: log.error_code,
      metadata: log.metadata
    }

    ActionCable.server.broadcast("live_stream", payload)

    MetricsTracker.record(payload.to_json.bytesize)
  end
end
