# frozen_string_literal: true
RSpec.describe Spot::JsonHelper do
  describe '.map_uris' do
    subject { helper.map_uris(values) }

    context 'when a value is a controlled resource' do
      let(:values) { [Spot::ControlledVocabularies::Base.new(URI('http://cool.example.org'))] }

      it { is_expected.to eq ['http://cool.example.org'] }
    end

    context 'when a value is a string' do
      let(:values) { ['http://cool.example.org/2'] }

      it { is_expected.to eq ['http://cool.example.org/2'] }
    end

    context 'when a value responds to #to_a' do
      let(:values) { OpenStruct.new(to_a: ['http://cool.example.org/3']) }

      it { is_expected.to eq ['http://cool.example.org/3'] }
    end
  end
end
