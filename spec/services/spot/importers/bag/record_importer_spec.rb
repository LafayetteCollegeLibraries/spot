# frozen_string_literal: true
RSpec.describe Spot::Importers::Bag::RecordImporter do
  subject(:importer) do
    described_class.new(work_class: work_class,
                        info_stream: dev_null,
                        error_stream: dev_null)
  end

  let(:work_class) { class_double('ActiveFedora::Base') }
  let(:dev_null) { File.open(File::NULL, 'w') }

  describe 'default_depositor_email' do
    let(:new_email) { 'cool@example.org' }

    it 'is settable' do
      expect { described_class.default_depositor_email = new_email }
        .to change { described_class.default_depositor_email }
        .to new_email
    end
  end

  describe '#import' do
    subject { importer.import(record: record) }

    let(:record) do
      Darlingtonia::InputRecord.from(metadata: metadata, mapper: mapper)
    end
    # the output from a record parser
    let(:metadata) do
      {
        'dc:title' => ['A good title'],
        'dc:author' => ['Name, Author'],
        'dc:keyword' => ['good', 'great'],
        'representative_files' => ['image.png']
      }
    end
    let(:mapper) { Spot::Mappers::BaseMapper.new }
    let(:work_double) { instance_double('ActiveFedora::Base') }

    # since we haven't passed a depositor, we need to expect the default one
    let(:depositor) do
      create(:user, email: described_class.default_depositor_email)
    end
    let(:ability) { Ability.new(depositor) }

    let(:attributes) do
      {
        title: metadata['dc:title'],
        author: metadata['dc:author'],
        keyword: metadata['dc:keyword'],
        visibility: mapper.class.default_visibility,
        remote_files: [{ url: 'file://image.png', name: 'image.png' }]
      }
    end
    let(:env_double) { instance_double('Hyrax::Actors::Environment') }
    let(:ability_double) { instance_double('Ability') }
    let(:actor_stack_double) { instance_double('Hyrax::Actors::AbstractActor') }

    before do
      mapper.class.fields_map = {
        title: 'dc:title',
        author: 'dc:author',
        keyword: 'dc:keyword'
      }

      allow(Ability)
        .to receive(:new)
        .with(depositor)
        .and_return(ability_double)

      allow(work_class)
        .to receive(:new)
        .and_return(work_double)

      allow(Hyrax::Actors::Environment)
        .to receive(:new)
        .with(work_double, ability, attributes)
        .and_return(env_double)

      allow(Hyrax::CurationConcern)
        .to receive(:actor)
        .and_return(actor_stack_double)

      allow(actor_stack_double).to receive(:create)

      importer.import(record: record)
    end

    it 'passes the expected arguments to actor.create' do
      expect(actor_stack_double)
        .to have_received(:create)
        .with(env_double)
    end
  end
end
