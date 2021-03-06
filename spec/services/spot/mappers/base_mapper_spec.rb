# frozen_string_literal: true
# rubocop:disable RSpec/InstanceVariable
RSpec.describe Spot::Mappers::BaseMapper do
  subject(:mapper) { described_class.new }

  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  describe '#fields' do
    subject { mapper.fields }

    before do
      @previous_fields_map = mapper.class.fields_map
      mapper.class.fields_map = { title: 'dc:title' }
    end

    after do
      mapper.class.fields_map = @previous_fields_map
    end

    it { is_expected.to eq [:title, :visibility] }
  end

  describe '#map_field' do
    before do
      @previous_fields_map = mapper.class.fields_map
      mapper.class.fields_map = fields_map
    end

    after do
      mapper.class.fields_map = @previous_fields_map
    end

    let(:fields_map) { { title: 'dc:title' } }
    let(:title_value) { ['Good work'] }
    let(:md_title) { 'dc:title' }
    let(:metadata) do
      { 'dc:title' => title_value, 'dc:subject' => ['Subjects'] }
    end

    it 'returns a mapped value' do
      expect(mapper.map_field(:title)).to eq title_value
    end

    it 'returns nil if field is not mapped' do
      expect(mapper.map_field(:subject)).to be nil
    end

    context 'when an array' do
      let(:fields_map) { { title: ['dc:title', 'another:title'] } }
      let(:metadata) do
        { 'dc:title' => ['Good work'], 'another:title' => ['Another title'] }
      end

      it 'gathers values for all fields + returns them' do
        expect(mapper.map_field(:title)).to eq ['Good work', 'Another title']
      end
    end
  end

  describe '#representative_file' do
    subject { mapper.representative_file }

    let(:paths) { ['/path/to/file', '/path/to/another'] }
    let(:metadata) { { 'representative_files' => paths } }

    it { is_expected.to eq paths }
  end

  describe '#visibility' do
    subject { mapper.visibility }

    context 'when none provided in metadata' do
      it { is_expected.to eq described_class.default_visibility }
    end

    context 'when defined in metadata' do
      let(:value) { 'open!' }
      let(:metadata) { { 'visibility' => value } }

      it { is_expected.to eq value }
    end
  end
end
# rubocop:enable RSpec/InstanceVariable
