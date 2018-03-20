RSpec.describe Hyrax::TrusteeDocumentForm do
  describe '.required_fields' do
    subject { described_class.required_fields }

    it { is_expected.to include :title }
    it { is_expected.to include :date_created }
    it { is_expected.to include :classification }
  end

  describe '.terms' do
    subject { described_class.terms }

    it { is_expected.to include :title }
    it { is_expected.to include :date_created }
    it { is_expected.to include :start_page }
    it { is_expected.to include :end_page }
    it { is_expected.to include :classification }
  end

  describe '.model_attributes' do
    subject { described_class.model_attributes(params) }

    context 'when :start_page and/or :end_page are present' do
      let(:params) do
        ActionController::Parameters.new(
          title: ['Meeting of the Board of Trustees'],
          date_created: ['2018-03-20'],
          start_page: '1234',
          end_page: '1289',
          classification: ['']
        )
      end

      it 'converts numeric strings to integers' do
        expect(subject['start_page']).to eq 1234
        expect(subject['end_page']).to eq 1289
      end
    end

    context 'when :start_page and/or :end_page are empty' do
      let(:params) do
        ActionController::Parameters.new(
          title: ['Meeting of the Board of Trustees'],
          date_created: ['2018-03-20'],
          start_page: '',
          end_page: '',
          classification: ['']
        )
      end

      it 'removes them' do
        expect(subject['start_page']).to be_empty
        expect(subject['end_page']).to be_empty
      end
    end
  end
end
