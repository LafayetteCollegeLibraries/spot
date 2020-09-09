# frozen_string_literal: true
RSpec.shared_examples 'it humanizes date fields' do |opts|
  opts ||= {}
  fields = opts[:for] || []

  raise 'No fields provided for example' if fields.empty?


  fields.each do |field|
    describe "for :#{field}" do
      subject { presenter.send(field.to_sym) }

      before do
        allow(presenter.solr_document).to receive(field.to_sym).and_return(original_value)
      end

      context 'YYYY-MM-DD values' do
        let(:original_value) { ['2020-09-09'] }

        it { is_expected.to eq ['September 9, 2020'] }
      end

      context 'YYYx' do
        let(:original_value) { ['202x'] }

        it { is_expected.to eq ['2020s'] }
      end

      context 'YYYY/YYYY' do
        let(:original_value) { ['1986/2020'] }

        it { is_expected.to eq ['1986 to 2020'] }
      end
    end
  end
end
