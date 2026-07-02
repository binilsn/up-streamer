# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe UpStreamer::Logger do
  subject(:logger) { described_class.new(client) }

  let(:client) { instance_spy(UpStreamer::Client) }

  it 'sends a log on info' do
    logger.info('test message')
    expect(client).to have_received(:send_log).with(hash_including(level: 'info', message: 'test message'))
  end

  it 'sends a log on error' do
    logger.error('something broke')
    expect(client).to have_received(:send_log).with(hash_including(level: 'error', message: 'something broke'))
  end

  it 'sends a log on warn' do
    logger.warn('warning')
    expect(client).to have_received(:send_log).with(hash_including(level: 'warn', message: 'warning'))
  end

  it 'sends a log on fatal' do
    logger.fatal('fatal error')
    expect(client).to have_received(:send_log).with(hash_including(level: 'critical', message: 'fatal error'))
  end
end
