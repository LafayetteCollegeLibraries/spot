describe Publication do
  subject(:pub) { described_class.new }

  describe '#title' do
    subject { pub.title }

    it_behaves_like 'a read and writable multiple property'

    context 'without a value' do
      it 'is not valid' do
        pub.valid?
        expect(pub.errors[:title]).to include 'Your work must have a title.'
      end
    end

    context 'with a value' do
      it 'is valid' do
        pub.title = ['Work title']
        expect(pub.valid?).to be true
      end
    end
  end

  describe '#publisher' do
    subject { pub.publisher }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#source' do
    subject { pub.source }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#resource_type' do
    subject { pub.resource_type }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#language' do
    subject { pub.language }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#abstract' do
    subject { pub.abstract }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#description' do
    subject { pub.description }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#identifier' do
    subject { pub.identifier }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#issued' do
    subject { pub.issued }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#available' do
    subject { pub.available }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#date_created' do
    subject { pub.date_created }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#creator' do
    subject { pub.creator }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#contributor' do
    subject { pub.contributor }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#rights_statement' do
    subject { pub.rights_statement }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#academic_department' do
    subject { pub.academic_department }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#division' do
    subject { pub.division }

    it_behaves_like 'a read and writable multiple property'
  end

  describe '#organization' do
    subject { pub.organization }

    it_behaves_like 'a read and writable multiple property'
  end
end
