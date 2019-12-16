# frozen_string_literal: true
module Spot::Importers::Base
  # A common-denominator descendent of +Darlingtonia::RecordImporter+ that
  # should work for most of our importing use-cases.
  #
  # @example Using our StreamLogger class for info/error logging
  #
  #   info_stream = Spot::StreamLogger.new(logger, level: ::Logger::INFO)
  #   error_stream = Spot::StreamLogger.new(logger, level: ::Logger::WARN)
  #   record_importer = Spot::Importers::Base::RecordImporter.new(work_class,
  #                                                               info_stream: info_stream,
  #                                                               error_stream: error_stream)
  class RecordImporter < ::Darlingtonia::RecordImporter
    BATCH_INGEST_KEY = :__part_of_batch_ingest__

    class_attribute :default_depositor_email, :default_admin_set_id
    self.default_depositor_email = 'dss@lafayette.edu'
    self.default_admin_set_id = AdminSet::DEFAULT_ID

    attr_reader :work_class, :admin_set_id, :collection_ids

    # Adds +work_class:+ and +admin_set_id:+ options to the RecordImporter initializer
    #
    # @param [ActiveFedora::Base] work_class
    # @param [AdminSet] admin_set
    # @param [#<<] info_stream
    # @param [#<<] error_stream
    def initialize(work_class:,
                   admin_set_id: default_admin_set_id,
                   collection_ids: [],
                   info_stream: STDOUT,
                   error_stream: STDOUT)
      super(info_stream: info_stream, error_stream: error_stream)
      @work_class = work_class
      @admin_set_id = admin_set_id
      @collection_ids = collection_ids
    end

    private

      # called from +#import+, which is inherited from
      # +Darlingtonia::RecordImporter+, but this does most of the work
      def create_for(record:)
        attributes = attributes_from_record(record)

        error_stream << empty_file_warning(attributes) if attributes[:remote_files].empty?

        work = work_class.new

        actor_env = Hyrax::Actors::Environment.new(work,
                                                   ability_for(attributes.delete(:depositor)),
                                                   attributes)

        info_stream << "Creating record: #{attributes[:title].first}\n"
        Hyrax::CurationConcern.actor.create(actor_env) &&
          (info_stream << "Record created: #{work.id}\n")
      rescue ::Ldp::Gone
        error_stream << "Ldp::Gone => [#{work.id}]\n"
      rescue => e
        error_stream << "#{e.message}\n"
      end

      # @return [Hash<Symbol => Array<*>]
      def attributes_from_record(record)
        record.attributes.tap do |attributes|
          attributes[BATCH_INGEST_KEY] = true
          attributes[:remote_files] = create_remote_files_list(record)
          attributes[:admin_set_id] ||= admin_set_id
          attributes[:member_of_collections_attributes] = collection_attributes unless collection_ids.empty?
        end
      end

      # determines the ability for an item based on the depositor's account.
      # creates a new User if email does not exist in database.
      #
      # @param [String] depositor_email
      # @return [Ability]
      def ability_for(depositor_email)
        depositor_email ||= default_depositor_email
        Ability.new(find_or_create_depositor(email: depositor_email))
      end

      # @return [Hash<String => Hash<String => String>>]
      def collection_attributes
        collection_ids.each_with_object({}).with_index do |(id, obj), idx|
          obj[idx.to_s] = { 'id' => id }
        end
      end

      # @return [Array<Hash<Symbol => String>>]
      def create_remote_files_list(record)
        Array.wrap(record.representative_file).map do |filename|
          url = filename.match?(%r{^https?://}) ? filename : "file://#{filename}"

          { url: url, name: File.basename(filename) }
        end
      end

      # @param [Hash] attributes
      # @return [String] an error message
      def empty_file_warning(attributes)
        "[WARN] no files found for #{Array.wrap(attributes[:title]).first}\n"
      end

      # @param [String] email
      # @return [User]
      def find_or_create_depositor(email:)
        user = User.find_or_initialize_by(email: email)

        # add 'depositor' role to user if:
        # - new record
        # - not already a depositor
        # - not an admin (can already deposit)
        if user.new_record? || (!user.depositor? && !user.admin?)
          user.roles << Role.find_by(name: 'depositor')
          user.save(validate: false)
        end

        user
      end
  end
end
