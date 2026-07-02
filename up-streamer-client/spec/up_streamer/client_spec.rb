# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe UpStreamer::Client do
  subject(:client) { described_class.new(endpoint: 'http://example.com/api/v1', token: 'abc123') }

  describe '#send_log' do
    it 'sends a POST request with auth header' do
      stub = stub_request(:post, 'http://example.com/api/v1/logs')
             .with(headers: { 'Authorization' => 'Bearer abc123' })
             .to_return(status: 201)

      result = client.send_log(level: 'info', message: 'hello')

      expect(result).to be true
      expect(stub).to have_been_requested
    end

    it 'includes a timestamp in the body' do
      stub = stub_request(:post, 'http://example.com/api/v1/logs')
             .with { |req| expect(JSON.parse(req.body)).to have_key('timestamp') }

      client.send_log(level: 'error', message: 'fail', timestamp: '2025-01-01T00:00:00.000Z')
      expect(stub).to have_been_requested
    end

    it 'includes metadata when provided' do
      stub = stub_request(:post, 'http://example.com/api/v1/logs')
             .with { |req| JSON.parse(req.body)['metadata'] == { 'env' => 'test' } }

      client.send_log(level: 'info', message: 'test', metadata: { env: 'test' })
      expect(stub).to have_been_requested
    end

    it 'defaults level to info' do
      stub = stub_request(:post, 'http://example.com/api/v1/logs').to_return(status: 201)

      client.send_log(message: 'no level given')
      expect(stub).to have_been_requested
    end
  end
end
