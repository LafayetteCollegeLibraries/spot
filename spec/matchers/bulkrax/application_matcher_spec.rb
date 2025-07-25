# frozen_string_literal: true
#
# @see app/services/concerns/spot/bulkrax_matcher_whitespace_patch.rb
# @see config/initializers/spot_overrides.rb
RSpec.describe Bulkrax::ApplicationMatcher do
  describe 'Spot patch' do
    let(:matcher) { described_class.new(split: /\|/, if: ['match?', /\r?\n/]) }

    it 'preserves newlines in content' do
      result = matcher.result(nil, "this is one line.\r\nthis is another one")
      expect(result).to eq("this is one line.\r\nthis is another one")
    end

    it 'replaces tabs with spaces' do
      result = matcher.result(nil, "this is the first line.\r\n\tand this is the second.\r\n\t\tand the third.")
      expect(result).to eq("this is the first line.\r\n and this is the second.\r\n  and the third.")
    end
  end
end
