# frozen_string_literal: true
RSpec.describe Spot::FileSetDerivativesService, derivatives: true do
  let(:_file_set) { build(:file_set) }
  let(:file_set) { _file_set }
  let(:fs_mime_type) { 'image/tiff' }

  before do
    allow(file_set).to receive(:mime_type).and_return(fs_mime_type)
  end

  it_behaves_like 'a Hyrax::DerivativeService' do
    let(:valid_file_set) { _file_set }
  end

  describe '#valid?' do
    subject { described_class.new(file_set).valid? }

    # valid mime_types
    ['image/tiff', 'application/pdf'].each do |mime_type|
      context "when mime_type is #{mime_type}" do
        let(:fs_mime_type) { mime_type }
        it { is_expected.to be true }
      end
    end

    # invalid mime_types
    ['application/vnd.ms-excel', 'video/mpeg', 'audio/wav'].each do |mime_type|
      context "when mime_type is #{mime_type}" do
        let(:fs_mime_type) { mime_type }
        it { is_expected.to be false }
      end
    end
  end
end
