# frozen_string_literal: true

module Spot::Importers::Bag
  class RecordImporter < Darlingtonia::RecordImporter
    class_attribute :default_depositor_email
    self.default_depositor_email = 'dss@lafayette.edu'

    attr_reader :work_class

    # Adds a +work_class:+ option to the RecordImporter initializer
    #
    # @param [ActiveFedora::Base] work_class
    # @param [#<<] info_stream
    # @param [#<<] error_stream
    def initialize(work_class:, info_stream: STDOUT, error_stream: STDOUT)
      super(info_stream: info_stream, error_stream: error_stream)
      @work_class = work_class
    end

    private

      # called from +#import+, which is inherited from
      # +Darlingtonia::RecordImporter+, but this does most of the work
      def create_for(record:)
        attributes = record.attributes
        attributes[:remote_files] = create_remote_files_list(record)

        error_stream << '[WARN] no files found for this bag\n' if attributes[:remote_files].empty?

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

      # determines the ability for an item based on the depositor's account.
      # creates a new User if email does not exist in database.
      #
      # @param [String] depositor_email
      # @return [Ability]
      def ability_for(depositor_email)
        depositor_email ||= default_depositor_email

        depositor = User.find_or_initialize_by(email: depositor_email)
        depositor.save(validate: false) if depositor.new_record?

        Ability.new(depositor)
      end

      # @return [Array<Hash<Symbol => String>>]
      def create_remote_files_list(record)
        (record.representative_file || []).map do |filename|
          { url: "file://#{filename}", name: File.basename(filename) }
        end
      end
  end
end
