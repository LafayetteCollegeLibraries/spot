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

    it { is_expected.to eq [:title] }
  end

  describe '#map_field' do
    before do
      @previous_fields_map = mapper.class.fields_map
      mapper.class.fields_map = { title: 'dc:title' }
    end

    after do
      mapper.class.fields_map = @previous_fields_map
    end

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
  end

  describe '#representative_file' do
    subject { mapper.representative_file }

    let(:paths) { ['/path/to/file', '/path/to/another'] }
    let(:metadata) { {representative_files: paths} }

    it { is_expected.to eq paths }
  end
end
