# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe UpStreamer::Logger do
  subject(:logger) { described_class.new(client, fallback_logger: fallback) }

  let(:client)   { instance_spy(UpStreamer::Client) }
  let(:fallback) { spy('fallback logger', add: nil) }

  around do |example|
    original_enabled = UpStreamer.config.enabled
    example.run
  ensure
    UpStreamer.config.enabled = original_enabled
  end

  describe 'when enabled' do
    before { UpStreamer.config.enabled = true }

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

    context 'when the client raises' do
      before do
        allow(client).to receive(:send_log).and_raise(Faraday::TimeoutError, 'connection timed out')
      end

      it 'writes to the fallback logger instead of crashing' do
        logger.warn('something slow')
        expect(fallback).to have_received(:add).with(::Logger::WARN, 'something slow', 'something slow')
      end

      it 'does not raise an exception' do
        expect { logger.error('boom') }.not_to raise_error
      end
    end

    context 'with default fallback (stderr)' do
      subject(:logger) { described_class.new(client) }

      before do
        allow(client).to receive(:send_log).and_raise(Faraday::ConnectionFailed, 'connection refused')
      end

      it 'writes to stderr and does not raise' do
        expect { logger.error('boom') }
          .to output(/boom/).to_stderr
      end
    end
  end

  describe 'when disabled' do
    before { UpStreamer.config.enabled = false }

    it 'does not call the remote client' do
      logger.info('offline message')
      expect(client).not_to have_received(:send_log)
    end

    it 'writes to the fallback logger' do
      logger.warn('fallback test')
      expect(fallback).to have_received(:add).with(::Logger::WARN, 'fallback test', 'fallback test')
    end

    context 'with default fallback (stderr)' do
      subject(:logger) { described_class.new(client) }

      it 'writes log to stderr' do
        expect { logger.info('service disabled') }
          .to output(/service disabled/).to_stderr
      end

      it 'does not call the remote client' do
        logger.info('service disabled')
        expect(client).not_to have_received(:send_log)
      end
    end
  end
end
