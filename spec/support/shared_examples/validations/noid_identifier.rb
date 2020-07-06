# frozen_string_literal: true
RSpec.shared_examples 'it ensures the existence of a NOID identifier' do
  let(:work_factory) { described_class.name.downcase.to_sym }
  let(:attributes) { attributes_for(work_factory) }

  # rubocop:disable RSpec/ExampleLength
  describe '#ensure_noid_in_identifier callback' do
    it 'inserts "noid:<id>" before save when an ID is present' do
      obj = described_class.new(attributes)
      obj.save

      noid_id = "noid:#{obj.id}"

      # it's a new record
      expect(obj.identifier).to include noid_id

      obj.identifier = ['abc:123']
      obj.save

      # adds the noid:<id>
      expect(obj.identifier).to contain_exactly 'abc:123', noid_id

      obj.identifier = []
      obj.save

      expect(obj.identifier).to contain_exactly noid_id
      obj.destroy!
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
