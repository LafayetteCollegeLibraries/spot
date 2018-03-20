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
end
