# frozen_string_literal: true
RSpec.describe Spot::AuthoritySelectService do
  subject(:service) { described_class.new }

  describe '#select_options_for' do
    subject { service.select_options_for(*keys) }

    context 'with one key passed' do
      let(:keys) { :geonames }

      it { is_expected.to contain_exactly('label' => 'GeoNames', 'search' => '/authorities/search/geonames') }
    end

    context 'with multiple keys passed' do
      let(:keys) { [:geonames, :tgn] }
      let(:results_array) do
        [
          {'label' => 'GeoNames', 'search' => '/authorities/search/geonames'},
          {'label' => 'Getty Thesaurus of Geo. Names', 'search' =>  '/authorities/search/getty/tgn'}
        ]
      end

      it { is_expected.to eq results_array }
    end

    context 'with an invalid key' do
      let(:keys) { [:nope, :doesnt_exist] }

      it { is_expected.to eq [] }
    end
  end
end
