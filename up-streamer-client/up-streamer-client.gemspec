# frozen_string_literal: true

require_relative 'lib/up-streamer-client/version'

Gem::Specification.new do |spec|
  spec.name          = 'up-streamer-client'
  spec.version       = UpStreamer::VERSION
  spec.authors       = ['binilsn']
  spec.summary       = 'Client gem for sending logs to the Up Streamer API'
  spec.description   = 'Send application logs to the Up Streamer log ingestion service with Faraday, auto-flush Rails notifications, and configurable retry.'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE']

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'faraday-retry', '~> 2.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
