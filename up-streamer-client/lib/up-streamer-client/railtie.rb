# frozen_string_literal: true

module UpStreamer
  class Railtie < Rails::Railtie
    initializer 'up_streamer.initialize' do
      client = UpStreamer::Client.new
      fallback = UpStreamer.config.fallback_logger || Rails.logger

      ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        next if event.payload[:controller] == 'api/v1/logs'

        log_controller_event(client, fallback, event)
      rescue StandardError => e
        fallback.warn("[up-streamer] Failed to process controller event: #{e.message}")
      end

      ActiveSupport::Notifications.subscribe(/perform.active_job/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        log_job_event(client, fallback, event)
      rescue StandardError => e
        fallback.warn("[up-streamer] Failed to process job event: #{e.message}")
      end
    end

    def self.log_controller_event(client, fallback, event)
      payload = event.payload
      level   = payload[:exception] ? 'error' : 'info'
      message = "#{payload[:method]} #{payload[:path]} -> #{payload[:status]}"
      metadata = {
        type: 'controller',
        controller: payload[:controller],
        action: payload[:action],
        status: payload[:status],
        duration: event.duration.round(2),
        exception: payload[:exception]&.first
      }

      if UpStreamer.config.enabled
        client.send_log(level: level, message: message, hostname: Socket.gethostname, metadata: metadata)
      else
        fallback.info("[up-streamer] #{message}")
      end
    rescue StandardError => e
      fallback.warn("[up-streamer] Failed to notify controller event: #{e.message}")
      fallback.info("[up-streamer] #{message}") if message
    end

    def self.log_job_event(client, fallback, event)
      payload = event.payload
      job     = payload[:job]
      level   = payload[:exception] ? 'error' : 'info'
      message = "#{job.class.name} ##{job.job_id}"
      metadata = {
        type: 'job',
        job_class: job.class.name,
        job_id: job.job_id,
        queue: job.queue_name,
        arguments: job.arguments.first(3),
        duration: event.duration.round(2),
        exception: payload[:exception]&.first
      }

      if UpStreamer.config.enabled
        client.send_log(level: level, message: message, hostname: Socket.gethostname, metadata: metadata)
      else
        fallback.info("[up-streamer] #{message}")
      end
    rescue StandardError => e
      fallback.warn("[up-streamer] Failed to notify job event: #{e.message}")
      fallback.info("[up-streamer] #{message}") if message
    end

    private_class_method :log_controller_event, :log_job_event
  end
end
