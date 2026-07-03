# frozen_string_literal: true

module UpStreamer
  class Config
    attr_accessor :api_endpoint, :access_token, :auto_flush, :auto_flush_interval

    def initialize
      @api_endpoint = ENV.fetch('UP_STREAMER_ENDPOINT', 'http://localhost:3001/api/v1')
      @access_token = ENV.fetch('UP_STREAMER_ACCESS_TOKEN', nil)
      @auto_flush = true
      @auto_flush_interval = 5
    end

    def validate!
      raise ArgumentError, 'api_endpoint is required' unless api_endpoint
      raise ArgumentError, 'access_token is required' unless access_token
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
