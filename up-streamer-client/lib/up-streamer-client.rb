# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

require_relative 'up-streamer-client/version'
require_relative 'up-streamer-client/config'
require_relative 'up-streamer-client/client'
require_relative 'up-streamer-client/logger'

begin
  require 'rails'
  require_relative 'up-streamer-client/railtie'
rescue LoadError
  # Not a Rails app — skip Railtie
end
