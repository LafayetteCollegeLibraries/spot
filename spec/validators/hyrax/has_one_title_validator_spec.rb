RSpec.describe Hyrax::HasOneTitleValidator do
  let(:validator) { described_class.new }

  context 'when an object has a title' do
    let(:object) { Collection.new }

    before do
      object.title = ['Cool Collection']
    end

    it 'validates' do
      validator.validate(object)

      expect(object.errors[:title]).to be_empty
    end
  end

  context 'when an object has a language-tagged title' do
    let(:object) { Collection.new }

    before do
      object.title = [RDF::Literal.new('Cool Collection', language: :en)]
    end

    it 'validates' do
      validator.validate(object)

      expect(object.errors[:title]).to be_empty
    end
  end

  context 'when an object has no title' do
    let(:object) { Collection.new }

    it 'adds an error to the object' do
      validator.validate(object)

      expect(object.errors[:title].size).to eq 1
      expect(object.errors[:title].first.to_s). to eq 'You must provide a title'
    end
  end
end
