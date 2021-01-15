# frozen_string_literal: true
RSpec.describe Spot::CatalogHelper, type: :helper do
  describe '#humanize_edtf_value' do
    subject { helper.humanize_edtf_value(value) }

    context 'when a value is parseable by Date.edtf' do
      let(:value) { '1912-06-01/2002-08-10' }

      it { is_expected.to eq 'June 1, 1912 to August 10, 2002' }
    end

    context 'when a value is not parseable by Date.edtf' do
      let(:value) { 'unparseable' }

      it { is_expected.to eq 'unparseable' }
    end
  end
end
