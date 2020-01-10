# frozen_string_literal: true
RSpec.shared_examples 'a RecordImporter' do |params|
  subject(:importer) do
    described_class.new(work_klass: work_klass,
                        admin_set_id: admin_set_id,
                        collection_ids: [collection_id],
                        info_stream: info_stream,
                        error_stream: error_stream)
  end

  let(:work_klass) { class_double('ActiveFedora::Base') }
  let(:dev_null) { File.open(File::NULL, 'w') }
  let(:admin_set_id) { 'an_admin_set' }
  let(:info_stream) { dev_null }
  let(:error_stream) { dev_null }
  let(:collection_id) { 'collection123' }

  # ensure that the role exists
  before(:all) { Role.find_or_create_by(name: 'depositor') }
  after(:all) { Role.find_by(name: 'depositor')&.destroy! }

  describe '#import' do
    subject(:import_record!) { importer.import(record: record) }

    let(:record) do
      ::Darlingtonia::InputRecord.from(metadata: metadata, mapper: mapper)
    end

    let(:mapper) { Spot::Mappers::BaseMapper.new }
    let(:metadata) { default_metadata }
    let(:attributes) { default_attributes }
    let(:default_metadata) do
      {
        'dc:title' => ['A good title'],
        'dc:author' => ['Name, Author'],
        'dc:keyword' => ['good', 'great'],
        'representative_files' => ['image.png']
      }
    end
    let(:default_attributes) do
      {
        title: metadata['dc:title'],
        author: metadata['dc:author'],
        keyword: metadata['dc:keyword'],
        visibility: mapper.class.default_visibility,
        remote_files: [{ url: 'file://image.png', name: 'image.png' }],
        admin_set_id: admin_set_id,
        member_of_collections_attributes: {
          '0' => { 'id' => collection_id }
        },
        described_class::BATCH_INGEST_KEY => true
      }
    end

    let(:work_double) { instance_double('ActiveFedora::Base', id: '', errors: []) }
    let(:depositor) do
      User.find_or_create_by(email: described_class.default_depositor_email)
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

      allow(work_klass)
        .to receive(:new)
        .and_return(work_double)

      allow(Hyrax::Actors::Environment)
        .to receive(:new)
        .with(work_double, ability_double, attributes)
        .and_return(env_double)

      allow(Hyrax::CurationConcern)
        .to receive(:actor)
        .and_return(actor_stack_double)

      allow(actor_stack_double).to receive(:create)
    end

    context 'when working properly' do
      before { import_record! }

      it 'passes the expected arguments to actor.create' do
        expect(actor_stack_double)
          .to have_received(:create)
          .with(env_double)
      end
    end

    context 'when no file attached' do
      let(:metadata) { default_metadata.merge('representative_files' => []) }
      let(:attributes) { default_attributes.merge(remote_files: []) }
      let(:error_message) { (params || {})[:empty_file_warning] || default_message }
      let(:default_message) { "[WARN] no files found for #{attributes[:title].first}\n" }

      before do
        allow(error_stream).to receive(:<<)
        import_record!
      end

      it 'writes a message to the error_stream' do
        expect(error_stream)
          .to have_received(:<<)
          .with(error_message)
      end
    end

    context 'when errors are raised' do
      before do
        allow(error_stream).to receive(:<<)
        allow(actor_stack_double).to receive(:create).and_raise(error)
        import_record!
      end

      context 'when an Ldp::Gone error is raised' do
        let(:error) { Ldp::Gone }

        it 'sends the message to the error_stream' do
          expect(error_stream).to have_received(:<<).with(/^Ldp::Gone/)
        end
      end

      context 'when an error is raised' do
        let(:error) { RuntimeError }

        it 'sends the message to the error_stream' do
          expect(error_stream).to have_received(:<<).with(/^RuntimeError/)
        end
      end
    end
  end
end
