# frozen_string_literal: true

module Spot::Importers::Bag
  class RecordImporter < Darlingtonia::RecordImporter
    class_attribute :default_depositor_email
    self.default_depositor_email = 'dss@lafayette.edu'

    # @todo add ability to set this (Image items will be coming in from Bags)
    # @return [Publication]
    def import_type
      ::Publication
    end

    private

    # called from +#import+, which is inherited from
    # +Darlingtonia::RecordImporter+, but this does most of the work
    def create_for(record:)
      info_stream << 'Creating record: ' \
                     "#{record.respond_to?(:title) ? record.title : record}.\n"

      created = import_type.new
      attributes = record.attributes

      ability = ability_for(attributes.delete(:depositor))

      attributes[:uploaded_files] = files(record.representative_file,
                                          user: ability.current_user)

      attributes[:visibility] = if record.respond_to? :visibility
                                  record.visibility
                                else
                                  default_visibility
                                end

      actor_env = environment.new(created, ability, attributes)

      Hyrax::CurationConcern.actor.create(actor_env) &&
        (info_stream << "Record created: #{created.id}\n")

    rescue Errno::ENOENT => e
      error_stream << e.message
    rescue ::Ldp::Gone => e
      error_stream << "Ldp::Gone => #{e.message}"
    end

    # determines the ability for an item based on the depositor's account.
    # creates a new User if email does not exist in database.
    #
    # @param [String] depositor_email
    # @return [Ability]
    def ability_for(depositor_email = default_depositor_email)
      depositor = User.find_or_initialize_by(email: depositor_email)
      depositor.save(validate: false) if depositor.new_record?

      Ability.new(depositor)
    end

    # Defaulting to 'open' visibility
    #
    # @return [String]
    def default_visibility
      ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    def environment
      Hyrax::Actors::Environment
    end

    # creates Hyrax::UploadedFile objects for each item in the +file_list+
    #
    # @param [Array<String>, NilClass] file_list an array of file paths
    # @option opts [User] :user the depositing user
    # @return [NilClass, Array<Number>]
    def files(file_list, user: nil)
      return if file_list.nil?

      # is it valid ruby to pass +User.find_by+ as a default parameter?
      if user.nil?
        user = User.find_by(email: default_depositor_email)
      end

      file_list.map do |file|
        Hyrax::UploadedFile.create(file: File.open(file), user: user).id
      end
    end
  end
end
