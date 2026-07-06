# frozen_string_literal: true

module UpStreamer
  class Config
    attr_accessor :api_endpoint, :access_token, :enabled, :fallback_logger

    def initialize
      @api_endpoint = ENV.fetch('UP_STREAMER_ENDPOINT', 'http://localhost:3001/api/v1')
      @access_token = ENV.fetch('UP_STREAMER_ACCESS_TOKEN', nil)
      @enabled = true
      @fallback_logger = nil
    end

    def validate!
      raise ArgumentError, 'api_endpoint is required' if api_endpoint.nil? || api_endpoint.empty?
      raise ArgumentError, 'access_token is required' if access_token.nil? || access_token.empty?
    end
  end

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
      config.validate!
    end
  end
end
