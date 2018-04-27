RSpec.describe Hyrax::TrusteeDocumentForm do
  describe '.required_fields' do
    subject { described_class.required_fields }

    it { is_expected.to include :title }
    it { is_expected.to include :date_created }
    it { is_expected.to include :source }
  end

  describe '.terms' do
    subject { described_class.terms }

    it { is_expected.to include :title }
    it { is_expected.to include :date_created }
    it { is_expected.to include :page_start }
    it { is_expected.to include :page_end }
    it { is_expected.to include :source }
  end

  describe '.model_attributes' do
    subject { described_class.model_attributes(params) }

    context 'when :page_start and/or :page_end are present' do
      let(:params) do
        ActionController::Parameters.new(
          title: ['Meeting of the Board of Trustees'],
          date_created: ['2018-03-20'],
          page_start: '1234',
          page_end: '1289',
          source: ['']
        )
      end

      it 'converts numeric strings to integers' do
        expect(subject['page_start']).to eq 1234
        expect(subject['page_end']).to eq 1289
      end
    end

    context 'when :page_start and/or :page_end are empty' do
      let(:params) do
        ActionController::Parameters.new(
          title: ['Meeting of the Board of Trustees'],
          date_created: ['2018-03-20'],
          page_start: '',
          page_end: '',
          source: ['']
        )
      end

      it 'removes them' do
        expect(subject['page_start']).to be_empty
        expect(subject['page_end']).to be_empty
      end
    end
  end
end
