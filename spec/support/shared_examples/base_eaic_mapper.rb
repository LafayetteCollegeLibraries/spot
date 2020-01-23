# frozen_string_literal: true
RSpec.shared_examples 'a base EAIC mapper' do
  it_behaves_like 'it has language-tagged titles'

  if described_class.new.fields.include?(:identifier)
    describe '#identifier' do
      subject { mapper.identifier }

      let(:title_field) { 'title.english' }

      context 'when a title has an ID in it' do
        let(:metadata) { { title_field => ['[ww0001] [A description of the object]'] } }

        it { is_expected.to include Spot::Identifier.new('eaic', 'ww0001').to_s }
      end
    end
  end
end
