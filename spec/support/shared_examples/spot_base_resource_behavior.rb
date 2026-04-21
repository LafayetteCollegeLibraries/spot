# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::BaseResourceBehavior' do
  describe '#identifier' do
    subject(:ids) { described_class.new(identifier: id_list).identifier }

    let(:prefix) { 'hdl' }
    let(:value) { '123:456/lol' }
    let(:raw_string) { "#{prefix}:#{value}" }
    let(:id_list) { [raw_string] }

    before do
      %w[hdl isbn].each { |p| Spot::Identifier.register_prefix(p) }
      # resource.identifier = id_list
    end

    it 'converts the strings to Spot::Identifiers' do
      expect(ids.length).to eq 1
      id = ids[0]
      expect(id.class).to eq Spot::Identifier
      expect(id.prefix).to eq prefix
      expect(id.value).to eq value
    end
  end
end