RSpec.describe Hyrax::TrusteeDocumentForm do
  describe '.required_fields' do
    subject { described_class.required_fields }
  end

  describe '.terms' do
    subject { described_class.terms }
  end
end
