# frozen_string_literal: true

require 'logger'

module UpStreamer
  class Logger < ::Logger
    def initialize(client = nil, progname: nil)
      @client = client || UpStreamer::Client.new
      super(nil)
      @progname = progname
      self.formatter = ->(_severity, _time, _progname, msg) { msg }
    end

    def add(severity, message = nil, progname = nil, &)
      msg = message || progname || yield
      return true unless msg

      level = severity_to_level(severity)
      @client.send_log(level: level, message: msg.to_s)
      true
    rescue StandardError => e
      warn "[up-streamer-client] Failed to send log: #{e.message}"
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
