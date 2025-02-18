# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  # An identifier that links this record to a Bulkrax import/export record.
  # For objects created within the Hyrax UI (_not_ Bulkrax), this will be
  # filled with a default value of ["ldr:#{work.id}"]
  #
  # This MUST be before the include declarations for the file to avoid an
  # error where the GeneratedResourceSchema for the FileSet does not include
  # Source_identifier.
  #
  # @todo find a better predicate for this field
  property :source_identifier, predicate: ::RDF::URI('http://ldr.lafayette.edu/ns#source_identifier') do |index|
    index.as :symbol, :stored_searchable
  end

  property :stored_derivatives, predicate: ::RDF::URI.new('http://ldr.lafayette.edu/ns#stored_derivatives') do |index|
    index.as :symbol
  end

  include ::Hyrax::FileSetBehavior
  include ::Spot::MetadataOnlyVisibility

  # Add the ability to attach a file labeled as a transcript.
  # Follows the implementation included via Hydra::Works::FileSetBehavior.
  # @see https://github.com/samvera/hydra-works/blob/v2.1.0/lib/hydra/works/models/concerns/file_set/contained_files.rb
  #
  # Use Hyrax::Actors::FileSetActor to attach a file.
  #
  # @example
  #   file_set = work.file_sets.first
  #   file = File.open('/path/to/file.vtt', 'r')
  #   job_io = JobIoWrapper.create_with_varied_file_handling!(user: uploading_user, file: file, relation: :transcript, file_set: file_set)
  #   Hyrax::Actors::FileSetActor.new(file_set, uploading_user).create_content(job_io, :transcript)
  #
  # @note in Hyrax 3.6.0, this value is stored in FileMetadata#type but as of Hyrax 5 it's been replaced with #pcdm_use.
  # @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/models/hyrax/file_metadata.rb#L68
  #
  # @todo In a modern Valkyrized Hyrax (>= 5.0.1), this info is stored at the Hyrax::FileMetadata level and retrieved via a search of the file_set's
  #       file_ids and filtering out those whose :pcdm_use includes the uri at Hyrax::FileMetadata::Use::TRANSCRIPT_FILE
  # @see https://github.com/samvera/hyrax/blob/hyrax-v5.0.1/app/controllers/concerns/hyrax/valkyrie_downloads_controller_behavior.rb#L93-L101
  # @see https://github.com/samvera/hyrax/blob/main/app/services/hyrax/custom_queries/find_file_metadata.rb#L61-L71
  directly_contains_one :transcript, through: :files, type: ::RDF::URI('http://pcdm.org/use#Transcript'), class_name: 'Hydra::PCDM::File'

  # using our own FileSetIndexer that doesn't index full-text content
  self.indexer = Spot::FileSetIndexer
end
