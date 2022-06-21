# frozen_string_literal: true
RSpec.describe Spot::Importers::CSV::RecordImporter, feature: :csv_ingest_service do
  let(:importer) do
    described_class.new(source_path: source_path,
                        info_stream: info_stream,
                        error_stream: error_stream,
                        admin_set_id: admin_set_id,
                        collection_ids: collection_ids)
  end
  let(:source_path) { '/path/to/source_path' }
  let(:info_stream) { File.open(File::NULL, 'w') }
  let(:error_stream) { File.open(File::NULL, 'w') }
  let(:admin_set_id) { 'an_admin_set' }
  let(:collection_ids) { [] }

  describe '#import' do
    let(:record) { Spot::Importers::CSV::InputRecord.from(metadata: metadata, mapper: mapper) }
    let(:_metadata) do
      { title: ['A Document to Import'],
        resource_type: ['Report'],
        rights_statement: ['http://creativecommons.org/publicdomain/mark/1.0/'],
        work_type: ['Publication'],
        files: ['files/document.pdf'] }
    end
    let(:metadata) { _metadata }
    let(:_parsed_attributes) do
      {
        title: ['A Document to Import'],
        resource_type: ['Report'],
        rights_statement: [RDF::URI.new('http://creativecommons.org/publicdomain/mark/1.0/')],
        visibility: mapper.class.default_visibility,
        remote_files: [{ url: "file://#{File.join(source_path, 'files/document.pdf')}", file_name: 'document.pdf' }],
        admin_set_id: admin_set_id
      }
    end
    let(:parsed_attributes) { _parsed_attributes }

    let(:mapper) { Spot::Importers::CSV::WorkTypeMapper.for(:publication) }
    let(:work) { mapper.work_type.new }
    let(:depositor) { FactoryBot.create(:depositor_user) }
    let(:ability) { Ability.new(depositor) }
    let(:actor_stack_double) { instance_double(Hyrax::Actors::AbstractActor, create: true) }
    let(:mock_environment) { instance_double(Hyrax::Actors::Environment, curation_concern: work, attributes: parsed_attributes) }

    before do
      allow(Hyrax::CurationConcern)
        .to receive(:actor)
        .and_return(actor_stack_double)

      allow(Hyrax::Actors::Environment)
        .to receive(:new)
        .with(instance_of(Publication), instance_of(Ability), hash_including(**parsed_attributes))
        .and_return(mock_environment)

      @old_default_depositor = described_class.default_depositor_email
      described_class.default_depositor_email = depositor.user_key
    end

    after do
      described_class.default_depositor_email = @old_default_depositor # rubocop:disable RSpec/InstanceVariable
    end

    it 'creates an environment to pass to the actor_stack' do
      importer.import(record: record)

      expect(actor_stack_double).to have_received(:create).with(mock_environment)
    end

    context 'when no file attached' do
      let(:metadata) { _metadata.merge(files: []) }
      let(:parsed_attributes) { _parsed_attributes.merge(remote_files: []) }
      let(:error_message) { "[WARN] No files found for #{parsed_attributes[:title].first}\n" }

      before do
        allow(error_stream).to receive(:<<)
      end

      it 'writes a message to the error_stream' do
        importer.import(record: record)

        expect(error_stream).to have_received(:<<).with(error_message)
      end
    end

    context 'when errors are raised' do
      before do
        allow(error_stream).to receive(:<<)
        allow(actor_stack_double).to receive(:create).and_raise(error)

        importer.import(record: record)
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
          expect(error_stream).to have_received(:<<).with(/^ERROR: RuntimeError/)
        end
      end
    end

    context 'when collection_ids are passed' do
      let(:collection_ids) { ['collection_1', 'collection_2'] }
      let(:parsed_attributes) { _parsed_attributes.merge(member_of_collections_attributes: collection_attributes) }
      let(:collection_attributes) do
        { '0' => { 'id' => 'collection_1' },
          '1' => { 'id' => 'collection_2' } }
      end

      it 'calls #create with member_of_collections attributes' do
        importer.import(record: record)

        expect(actor_stack_double).to have_received(:create).with(mock_environment)
      end
    end

    context 'when a work has errors attached' do
      before do
        allow(work).to receive(:errors).and_return(error_messages)
        allow(error_stream).to receive(:<<)

        importer.import(record: record)
      end

      let(:error_messages) do
        ActiveModel::Errors.new(work).tap do |errors|
          errors[:rights_statement] << 'Your work must include a Rights Statement'
        end
      end

      it 'sends the message to the error_stream' do
        expect(error_stream).to have_received(:<<).with('ERROR [Publication#rights_statement] Your work must include a Rights Statement\n')
      end
    end

    context 'when a "depositor" is passed in the metadata' do
      let(:metadata) { _metadata.merge(depositor: [depositor_email]) }
      let(:depositor_email) { 'no-reply@lafayette.edu' }
      let(:depositor_user) { User.find_by(email: depositor_email) }

      before do
        User.where(email: depositor_email).destroy_all
        expect(User.find_by(email: depositor_email)).to be_nil

        importer.import(record: record)
      end

      it 'creates a User account for the email address' do
        expect(User.find_by(email: depositor_email)).not_to be_nil
      end
    end
  end
end
