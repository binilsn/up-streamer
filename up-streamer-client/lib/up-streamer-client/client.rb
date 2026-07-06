# frozen_string_literal: true

module UpStreamer
  class Client
    attr_reader :endpoint, :token

    def initialize(endpoint: nil, token: nil)
      @endpoint = (endpoint || UpStreamer.config.api_endpoint).to_s
      @token    = (token    || UpStreamer.config.access_token).to_s
    end

    def send_log(message:, level: 'info', hostname: nil, error_code: nil, timestamp: nil, metadata: {})
      return true unless UpStreamer.config.enabled
      return false if @token.nil? || @token.empty?

      payload = build_payload(message, level, hostname, error_code, timestamp, metadata)

      response = connection.post('logs') do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{@token}"
        req.body = payload.to_json
      end

      response.success?
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      false
    rescue Faraday::Error => e
      warn "[up-streamer-client] HTTP error: #{e.message}"
      false
    end

    private

    def build_payload(message, level, hostname, error_code, timestamp, metadata)
      {
        level: level,
        message: message,
        hostname: hostname,
        error_code: error_code,
        timestamp: timestamp || Time.now.utc.iso8601(3),
        metadata: metadata
      }.compact
    end

    def connection
      @connection ||= Faraday.new(url: @endpoint) do |f|
        f.options.timeout      = 3  # read timeout
        f.options.open_timeout = 2  # connect timeout
        f.request :retry, max: 1, interval: 0.5, backoff_factor: 2
        f.adapter Faraday.default_adapter
      end
    end
  end
end
