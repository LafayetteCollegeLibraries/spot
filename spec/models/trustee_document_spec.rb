RSpec.describe TrusteeDocument do
  let(:page_number) { 1234 }
  let(:title) { ['Title of Document'] }

  describe '#page_start' do
    it 'should be an integer' do
      expect { described_class.create!(title: title, page_start: '1234') }
        .to raise_error(ActiveFedora::RecordInvalid)
    end

    it 'can be nil' do
      expect { described_class.create!(title: title, page_start: nil) }
        .not_to raise_error
    end

    it 'can be an empty string' do
      expect { described_class.create!(title: title, page_start: '') }
        .not_to raise_error
    end

    context 'with a new TrusteeDocument' do
      subject { described_class.new }

      its(:page_start) { is_expected.to be_nil }
    end

    context 'with a doc that has a start page' do
      subject do
        described_class.new.tap do |doc|
          doc.page_start = page_number
        end
      end

      its(:page_start) { is_expected.to eq page_number }
    end
  end

  describe '#page_end' do
    it 'should be an integer' do
      expect { described_class.create!(title: title, page_end: '1234') }
        .to raise_error(ActiveFedora::RecordInvalid)
    end

    it 'can be nil' do
      expect { described_class.create!(title: title, page_end: nil) }
        .not_to raise_error
    end

    it 'can be an empty string' do
      expect { described_class.create!(title: title, page_end: '') }
        .not_to raise_error
    end

    context 'with a new TrusteeDocument' do
      subject { described_class.new }

      its(:page_end) { is_expected.to be_nil }
    end

    context 'with a doc that has a end page' do
      subject do
        described_class.new.tap do |doc|
          doc.page_end = page_number
        end
      end

      its(:page_end) { is_expected.to eq page_number }
    end
  end
end
