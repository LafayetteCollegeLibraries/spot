RSpec.describe Trustee::Document do
  let(:page_number) { 1234 }
  let(:title) { ['Title of Document'] }

  its(:human_readable_type) { should eq 'Trustee Document' }

  describe '#start_page' do
    it 'should be an integer' do
      expect { described_class.create!(title: title, start_page: '1234') }
        .to raise_error(ActiveFedora::RecordInvalid)
    end

    it 'can be nil' do
      expect { described_class.create!(title: title, start_page: nil) }
        .not_to raise_error
    end

    context 'with a new Trustee::Document' do
      subject { described_class.new }

      its(:start_page) { is_expected.to be_nil }
    end

    context 'with a doc that has a start page' do
      subject do
        described_class.new.tap do |doc|
          doc.start_page = page_number
        end
      end

      its(:start_page) { is_expected.to eq page_number }
    end
  end

  describe '#end_page' do
    it 'should be an integer' do
      expect { described_class.create!(title: title, end_page: '1234') }
        .to raise_error(ActiveFedora::RecordInvalid)
    end

    it 'can be nil' do
      expect { described_class.create!(title: title, end_page: nil) }
        .not_to raise_error
    end

    context 'with a new Trustee::Document' do
      subject { described_class.new }

      its(:end_page) { is_expected.to be_nil }
    end

    context 'with a doc that has a end page' do
      subject do
        described_class.new.tap do |doc|
          doc.end_page = page_number
        end
      end

      its(:end_page) { is_expected.to eq page_number }
    end
  end
end
