# frozen_string_literal: true
module Spot::Importers::CSV
  # Service responsible for transforming parsed metadata (via `InputRecord`s)
  # into individual Hyrax objects. This deals with the monstly non-metadata
  # side of creating the objects: assigning and attaching files, setting admin_set
  # and collection info, and kicking off the ingest process.
  #
  # @example
  #   source_root = '/imports/new-batch'
  #   csv_file = File.open(File.join(source_root, 'new_works_metadata.csv'), 'r')
  #   parser = Spot::Importers::CSV::Parser.new(file: csv_file)
  #   record_importer = Spot::Importers::CSV::RecordImporter.new(source_path: File.join(source_root, 'files'))
  #
  #   parser.records do |record|
  #     record_importer.import(record: record)
  #   end
  class RecordImporter < ::Darlingtonia::RecordImporter
    class_attribute :default_depositor_email, :default_admin_set_id
    self.default_depositor_email = Hyrax.config.batch_user_key
    self.default_admin_set_id = AdminSet::DEFAULT_ID

    attr_reader :source_path, :admin_set_id, :collection_ids

    def initialize(source_path:,
                   info_stream: Darlingtonia.config.default_error_stream,
                   error_stream: Darlingtonia.config.default_error_stream,
                   admin_set_id: default_admin_set_id,
                   collection_ids: [])
      super(info_stream: info_stream, error_stream: error_stream)

      @source_path = source_path
      @admin_set_id = admin_set_id
      @collection_ids = collection_ids
    end

    private

    # Called from within `import(record:)` which handles exceptions that may be raised.
    #
    #
    def create_for(record:)
      info_stream << "Creating record #{record&.title || record}"

      created = ingest(record)

      info_stream << "Created work ID=#{created.id}" if created.persisted?

      created.errors.each do |field, message|
        error_stream << "ERROR [#{work_type(record)}##{field}] #{message}"
      end

      created
    rescue ::Ldp::Gone
      error_stream << "Ldp::Gone => #{record&.title || record}]\n"
    rescue => e
      error_stream << "#{e.message}\n"
    end

    def ingest(record)
      env = environment_from_record(record)
      error_stream << empty_file_warning(env.attributes) if env.attributes[:remote_files].empty?

      Hyrax::CurationConcern.actor.create(env)

      env.curation_concern
    end

    def ability_for(user_email)
      user_email ||= default_depositor_email
      Ability.new(User.find_or_create_by(email: user_email))
    end

    def attributes_from_record(record)
      record.attributes.tap do |attributes|
        attributes[:remote_files] = create_remote_files_list(record)
        attributes[:admin_set_id] ||= admin_set_id
        attributes[:member_of_collections_attributes] = collection_attributes unless collection_ids.empty?
      end
    end

    def collection_attributes
      collection_ids.each_with_object({}).with_index do |(id, obj), idx|
        obj[idx.to_s] = { 'id' => id }
      end
    end

    def create_remote_files_list(record)
      Array.wrap(record.representative_file).map do |filename|
        url = filename if filename.start_with?('file://', 'http://', 'https://')
        url ||= "file://#{File.join(source_path, filename)}"

        { url: url, file_name: File.basename(filename) }
      end
    end

    def empty_file_warning(attributes)
      "[WARN] No files found for #{Array.wrap(attributes[:title]).first}\n"
    end

    def environment_from_record(record)
      work = work_type(record).new
      attributes = attributes_from_record(record)
      ability = ability_for(attributes.delete(:depositor)&.first) # attributes are always parsed as array values

      Hyrax::Actors::Environment.new(work, ability, attributes)
    end

    def work_type(record)
      record.mapper.work_type
    end
  end
end
