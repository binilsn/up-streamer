# frozen_string_literal: true

module UpStreamer
  class Railtie < Rails::Railtie
    initializer 'up_streamer.initialize' do
      client = UpStreamer::Client.new

      ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)

        client.send_log(
          level: event.payload[:exception] ? 'error' : 'info',
          message: "#{event.payload[:method]} #{event.payload[:path]} -> #{event.payload[:status]}",
          hostname: Socket.gethostname,
          metadata: {
            controller: event.payload[:controller],
            action: event.payload[:action],
            status: event.payload[:status],
            duration: event.duration.round(2),
            exception: event.payload[:exception]&.first
          }
        )
      rescue StandardError => e
        Rails.logger.warn("[up-streamer] Failed to notify: #{e.message}")
      end
    end
  end
end
