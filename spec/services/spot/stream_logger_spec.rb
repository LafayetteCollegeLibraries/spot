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

    context 'when a method does not exist' do
      it 'passes it down' do
        expect { stream_logger.this_method_doesnt_exist }
          .to raise_error(NoMethodError)
      end

      it 'also knows when to say it doesn\'t know how' do
        expect(stream_logger.respond_to?(:nope_not_me_either))
          .to be false
      end
    end
  end
end
