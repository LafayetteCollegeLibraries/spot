RSpec.describe Spot::IngestZippedBag do
  describe '.new' do
    it 'raises an ArgumentError if no source provided' do
      expect { described_class.new('/path/to.zip') }
        .to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if source is unknown' do
      expect { described_class.new('/path/to.zip', source: :nope) }
        .to raise_error(ArgumentError)
    end
  end
end
