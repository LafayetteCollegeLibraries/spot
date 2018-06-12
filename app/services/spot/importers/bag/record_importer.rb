module Spot::Importers::Bag
  class RecordImporter < Darlingtonia::RecordImporter
    def import_type
      ::Publication
    end

    private

    def ability
      Ability.new(creator)
    end

    def creator
      User.find_by(email: 'malantoa@lafayette.edu')
    end

    def create_for(record:)
      info_stream << 'Creating record: ' \
                     "#{record.respond_to?(:title) ? record.title : record}.\n"

      created = import_type.new
      attributes = record.attributes
      attributes[:uploaded_files] = files(record.representative_file)
      attributes[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      actor_env = Hyrax::Actors::Environment.new(created, ability, attributes)

      Hyrax::CurationConcern.actor.create(actor_env)

      info_stream << "Record created: #{created.id}\n"
    rescue Errno::ENOENT => e
      error_stream << e.message
    end

    def files(file_list)
      return if file_list.nil?

      file_list.map do |file|
        Hyrax::UploadedFile.create(file: File.open(file), user: creator).id
      end
    end
  end
end
