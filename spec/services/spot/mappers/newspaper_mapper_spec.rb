RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#based_near_attributes' do
    subject(:based_near_attributes) { mapper.based_near_attributes }

    let(:expected_value) do
      { '0' => { 'id' => 'http://sws.geonames.org/5188140/' } }
    end

    context 'when location is Easton' do
      let(:metadata) do
        {
          'dc:coverage' => ['United States, Pennsylvania, Northampton County, Easton']
        }
      end

      it { is_expected.to eq expected_value }
    end

    context 'when location is not in our internal mapping' do
      before do
        @original_logger = Rails.logger

        class FakeLogger < Logger
          attr_reader :messages
          def initialize(*args)
            super(File::NULL)
            @messages = []
          end

          def add(*args)
            @messages << args
            super(*args)
          end
        end

        Rails.logger = logger
      end

      after do
        Rails.logger = @original_logger
        Object.send(:remove_const, :FakeLogger)
      end

      let(:logger) { FakeLogger.new(File::NULL)  }
      let(:metadata) { {'dc:coverage' => ['Coolsville, Daddy-O']} }

      it 'writes a warning to the logger' do
        expect(based_near_attributes).to be_empty
        expect(logger.messages).not_to be_empty
        expect(logger.messages.first.first).to eq Logger::WARN
      end
    end
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:value) do
      %w[
        2018-09-01
        2018-09-02
      ]
    end

    let(:metadata) do
      {
        'dc:date' => %w[
          2018-09-01T00:00:00Z
          2018-09-02T00:00:00Z
        ]
      }
    end

    it { is_expected.to eq value }
  end

  describe '#description' do
    subject { mapper.description }

    let(:field) { 'dc:description' }

    it_behaves_like 'a mapped field'
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:field) { 'dc:identifier' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'dc:subject' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'dc:source' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'dc:publisher' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'dc:type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject(:rights_statement) { mapper.rights_statement }

    let(:metadata) { {'dc:rights' => [rights]} }

    skip 'when in the Public domain' do
      let(:rights) { 'Public domain' }

      it 'is an RDF::URI' do
        expect(rights_statement.first).to be_an ::RDF::URI
      end
    end

    context 'when not in the Public domain' do
      let(:rights) { 'No way you can use this' }

      it 'keeps the existing value' do
        expect(rights_statement.first).to eq rights
      end
    end
  end

  describe '#title' do
    subject { mapper.title }

    let(:field) { 'dc:title' }

    it_behaves_like 'a mapped field'
  end
end
