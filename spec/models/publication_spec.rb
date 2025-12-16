# frozen_string_literal: true
RSpec.describe Publication do
  subject { described_class.new }
  it_behaves_like 'it includes Spot::WorkBehavior'

  it { is_expected.to respond_to :date_available, :date_available= }
  it { is_expected.to respond_to :date_issued, :date_issued= }
  it { is_expected.to respond_to :division, :division= }
  it { is_expected.to respond_to :editor, :editor= }
  it { is_expected.to respond_to :license, :license= }
  it { is_expected.to respond_to :organization, :organization= }

  describe 'validations' do
    let(:work) { build(:publication) }

    describe 'date_issued' do
      it 'can not be absent' do
        work.title = ['cool title'] # need this to validate
        work.date_issued = []

        expect(work.valid?).to be false
        expect(work.errors[:date_issued]).to include 'Date Issued may not be blank'
      end

      it 'can not be spelled out' do
        work.date_issued = ['September 21, 2019']

        expect(work.valid?).to be false
        expect(work.errors[:date_issued]).to include 'Date Issued must be in YYYY-MM-DD, YYYY-MM, or YYYY format'
      end

      it 'can not have multiple values' do
        work.date_issued = ['2019-09-21', '2019-11-19']

        expect(work.valid?).to be false
        expect(work.errors[:date_issued]).to include 'Date Issued may only contain one value'
      end

      it 'can be YYYY-MM-DD' do
        work.date_issued = ['2019-09-21']

        expect(work.valid?).to be true
      end

      it 'can be YYYY-MM' do
        work.date_issued = ['2019-09']

        expect(work.valid?).to be true
      end

      it 'can be YYYY' do
        work.date_issued = ['2019']

        expect(work.valid?).to be true
      end
    end

    describe 'rights_statement' do
      let(:uri) { 'http://creativecommons.org/publicdomain/mark/1.0/' }

      it 'can be an ActiveTriples::Resource' do
        work.rights_statement = [ActiveTriples::Resource.new(RDF::URI(uri))]
        expect(work.valid?).to be true
      end
    end
  end
end
