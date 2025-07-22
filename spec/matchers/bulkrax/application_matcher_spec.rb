# frozen_string_literal: true
RSpec.describe Bulkrax::ApplicationMatcher do
  describe 'Spot patch' do
    # it 'is included' do
    #   expect(described_class.ancestors).to include(Spot::BulkraxMatcherWhitespacePatch)
    # end

    it 'preserves newlines in content' do
      matcher = described_class.new(split: /\|/)
      result = matcher.result(nil, "this is one line.\r\nthis is another one")
      expect(result).to eq("this is one line.\r\nthis is another one")
    end
  end
end