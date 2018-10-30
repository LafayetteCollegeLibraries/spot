# note: I _hate, hate, hate_ how this test is set up, but it was a necessary evil
# to get _some_ kind of testing that was more than just checking that the importer
# calls +Hyrax::CurationConcern.actor.create+ without checking what it's sending.
# there's _way_ too much mocking going on for my taste, but we're creating a
# bunch of +.new+ things and need to ensure that they're the same thing (previously
# I was getting non-equality errors bc of different new objects being called).
#
# @todo PLEASE find a way to refactor this.
RSpec.describe Spot::Importers::Bag::RecordImporter do
  let(:importer) { described_class.new }
  let(:ability) { Ability.new(depositor) }
  let(:depositor) { User.find_or_initialize_by(email: 'example@lafayette.edu') }
  let(:environment) { double('environment') }
  let(:file_list) { [1] }
  let(:mapper) { Spot::Mappers::BaseHashMapper.new }
  let(:metadata) do
    {
      'title' => ['thee title'],
      'depositor' => depositor.email,
      'visibility' => 'private',
      'representative_files' => ['/path/to/file'],
    }
  end
  let(:attributes) do
    {
      title: ['thee title'],
      visibility: 'private',
      uploaded_files: [1]
    }
  end
  let(:new_publication) { Publication.new }
  let(:record) { Darlingtonia::InputRecord.from(metadata: metadata, mapper: mapper) }
  let(:mock_import_type) { double('import type') }

  let(:expected_environment) do
    Hyrax::Actors::Environment.new(new_publication, ability, attributes)
  end

  before do
    mapper.class.fields_map = { title: 'title', visibility: 'visibility' }
    mapper.metadata = metadata

    allow(importer).to receive(:files).and_return(file_list)
    allow(importer).to receive(:import_type).and_return(mock_import_type)
    allow(importer).to receive(:ability_for).and_return(ability)
    allow(importer).to receive(:environment).and_return(environment)

    allow(mock_import_type).to receive(:new).and_return(new_publication)
    allow(environment)
      .to receive(:new)
      .with(new_publication, ability, attributes)
      .and_return(expected_environment)
  end

  after do
    depositor.destroy
  end

  # we don't explicitly define this method in our subclass
  # but it's essentially a wrapper for our own defined
  # +#create_for+, so it requires some testing.
  describe '#import' do
    it 'receives the expected environment object' do
      expect(Hyrax::CurationConcern.actor)
        .to receive(:create)
        .with(expected_environment)

      importer.import(record: record)
    end
  end
end
