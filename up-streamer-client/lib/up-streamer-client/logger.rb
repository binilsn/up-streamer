# frozen_string_literal: true

require 'logger'

module UpStreamer
  class Logger < ::Logger
    def initialize(client = nil, fallback_logger: nil, progname: nil)
      @client = client || UpStreamer::Client.new
      @fallback_logger = fallback_logger || UpStreamer.config.fallback_logger || ::Logger.new($stderr)
      super(nil)
      @progname = progname
      self.formatter = ->(_severity, _time, _progname, msg) { msg }
    end

    def add(severity, message = nil, progname = nil, &)
      msg = message || progname || yield
      return true unless msg

      if UpStreamer.config.enabled
        level = severity_to_level(severity)
        @client.send_log(level: level, message: msg.to_s)
      else
        @fallback_logger.add(severity, msg, progname)
      end
      true
    rescue StandardError
      @fallback_logger.add(severity, msg, progname)
      true
    end

    private

    def severity_to_level(severity)
      case severity
      when ::Logger::DEBUG then 'debug'
      when ::Logger::WARN  then 'warn'
      when ::Logger::ERROR then 'error'
      when ::Logger::FATAL then 'critical'
      else                      'info'
      end
    end
  end
end
