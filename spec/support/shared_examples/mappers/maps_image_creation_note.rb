# frozen_string_literal: true
RSpec.shared_examples 'it maps image creation note' do
  describe '#note' do
    subject { mapper.note }

    let(:mapper) { described_class.new }
    let(:field) { described_class.image_creation_note_field }
    let(:metadata) { { field => value } }

    before { mapper.metadata = metadata }

    context 'when a value exists' do
      let(:value) { 'Created on an Epson scanner' }

      it { is_expected.to eq value }
    end

    context 'when no value exists' do
      let(:metadata) { { 'title' => ['work title'] } }

      it { is_expected.to be_empty }
    end

    context 'when value contains magic string' do
      let(:value) do
        'Master TIF image captured at 4000 pixels across the long edge using SilverFast AI 6.6 software and an Epson v700 scanner. Online display image was converted to JPG format.'
      end

      it { is_expected.to eq ['Master TIF image captured at 4000 pixels across the long edge using SilverFast AI 6.6 software and an Epson v700 scanner.'] }
    end
  end
end
