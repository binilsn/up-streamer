# frozen_string_literal: true

module UpStreamer
  class Railtie < Rails::Railtie
    initializer 'up_streamer.initialize' do
      client = UpStreamer::Client.new

      ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
        next unless UpStreamer.config.enabled

        event = ActiveSupport::Notifications::Event.new(*args)
        next if event.payload[:controller] == 'api/v1/logs'

        client.send_log(
          level: event.payload[:exception] ? 'error' : 'info',
          message: "#{event.payload[:method]} #{event.payload[:path]} -> #{event.payload[:status]}",
          hostname: Socket.gethostname,
          metadata: {
            type: 'controller',
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

      ActiveSupport::Notifications.subscribe(/perform.active_job/) do |*args|
        next unless UpStreamer.config.enabled

        event = ActiveSupport::Notifications::Event.new(*args)
        job = event.payload[:job]

        client.send_log(
          level: event.payload[:exception] ? 'error' : 'info',
          message: "#{job.class.name} ##{job.job_id}",
          hostname: Socket.gethostname,
          metadata: {
            type: 'job',
            job_class: job.class.name,
            job_id: job.job_id,
            queue: job.queue_name,
            arguments: job.arguments.first(3),
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
