RSpec.describe Qa::Authorities::Language do
  let(:authority) { described_class.new }

  describe '#all' do
    subject(:set) { authority.all }

    it { is_expected.to be_an Array }
    it { is_expected.not_to be_empty }

    it 'contains hashes with an `:id` and a `:label`' do
      set.each do |entry|
        expect(entry).to include :id, :label
      end
    end
  end

  describe '#find' do
    subject { authority.find(id) }


    context 'when an entry exists' do
      let(:id) { 'en' }

      it { is_expected.to be_a Hash }
      it { is_expected.to eq({id: 'en', label: 'English', value: 'en'}) }
    end

    context 'when an entry does not exist' do
      let(:id) { ':(((' }

      it { is_expected.to be_nil }
    end
  end

  describe '#search' do
    subject { authority.search(query) }

    context 'when a search has results' do
      let(:query) { 'esperanto' }

      it { is_expected.to be_an Array }
      it { is_expected.not_to be_empty }
    end

    context 'when a search has no results' do
      let(:query) { 'NOPE NOT A LANGUAGE' }

      it { is_expected.to be_an Array }
      it { is_expected.to be_empty }
    end
  end
end
