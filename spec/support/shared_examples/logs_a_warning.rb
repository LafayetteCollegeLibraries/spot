shared_examples 'it logs a warning' do
  before do
    @original_logger = Rails.logger

    class FakeLogger < Logger
      attr_reader :messages
      def initialize(*args)
        super(File::NULL)
        @messages = []
      end

      def add(*args)
        @messages << args
        super(*args)
      end
    end

    Rails.logger = logger
  end

  after do
    Rails.logger = @original_logger
    Object.send(:remove_const, :FakeLogger)
  end

  let(:logger) { FakeLogger.new(File::NULL) }

  it do
    # we need to call the subject, otherwise nothing will happen
    # and +logger.messages+ will be empty
    subject

    expect(logger.messages).not_to be_empty
    expect(logger.messages.first.first).to eq Logger::WARN
  end
end
