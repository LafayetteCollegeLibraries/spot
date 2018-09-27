module Spot::Importers::Bag
  class RecordImporter < Darlingtonia::RecordImporter
    def import_type
      ::Publication
    end

    private

    def creator
      User.find_by(email: 'dss@lafayette.edu')
    end

    def create_for(record:)
      info_stream << 'Creating record: ' \
                     "#{record.respond_to?(:title) ? record.title : record}.\n"

      created = import_type.new
      attributes = record.attributes

      depositor_email = attributes.delete(:depositor)
      depositor_email ||= 'dss@lafayette.edu'
      depositor = User.find_or_initialize_by(email: depositor_email)
      depositor.save(validate: false) if depositor.new_record?

      ability = Ability.new(depositor)

      attributes[:uploaded_files] = files(record.representative_file, user: depositor)
      attributes[:visibility] = if record.respond_to? :visibility
                                  record.visibility
                                else
                                  default_visibility
                                end

      puts attributes.inspect

      actor_env = Hyrax::Actors::Environment.new(created, ability, attributes)

      Hyrax::CurationConcern.actor.create(actor_env) &&
        (info_stream << "Record created: #{created.id}\n")

    rescue Errno::ENOENT => e
      error_stream << e.message
    rescue ::Ldp::Gone => e
      error_stream << "Ldp::Gone => #{e.message}"
    end

    def default_visibility
      ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    def files(file_list, user: creator)
      return if file_list.nil?

      file_list.map do |file|
        Hyrax::UploadedFile.create(file: File.open(file), user: user).id
      end
    end
  end
end
