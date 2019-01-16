# frozen_string_literal: true

RSpec.describe Spot::StreamLogger do
  subject(:stream_logger) { described_class.new(logger, level: level) }

  let(:dev_null) { File.open(File::NULL, 'w') }
  let(:logger) { Logger.new(dev_null) }
  let(:level) { Logger::INFO }
  let(:message) { 'cool beans' }

  describe '#<<' do
    before do
      allow(logger).to receive(:log)
    end

    it 'sends the message to logger at level' do
      stream_logger << message

      expect(logger).to have_received(:log).with(level, message)
    end
  end

  describe '#method_missing' do
    before do
      allow(logger).to receive(:warn)
    end

    it 'sends other stuff to the logger' do
      stream_logger.warn(message)

      expect(logger).to have_received(:warn).with(message)
    end
  end
end
