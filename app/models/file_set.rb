# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
  include ::Spot::MetadataOnlyVisibility

  # An identifier that links this record to a Bulkrax import/export record.
  # For objects created within the Hyrax UI (_not_ Bulkrax), this will be
  # filled with a default value of ["ldr:#{work.id}"]
  #
  # @todo find a better predicate for this field
  property :source_identifier, predicate: ::RDF::URI('http://ldr.lafayette.edu/ns#source_identifier') do |index|
    index.as :symbol, :stored_searchable
  end

  # Add the ability to attach a file labeled as a transcript.
  # Follows the implementation included via Hydra::Works::FileSetBehavior.
  # @see https://github.com/samvera/hydra-works/blob/v2.1.0/lib/hydra/works/models/concerns/file_set/contained_files.rb
  #
  # Use Hyrax::Actors::FileSetActor to attach a file.
  #
  # @example
  #   file_set = work.file_sets.first
  #   job_io = JobIoWrapper.create_with_varied_file_handling(user: uploading_user, file: '/path/to/file.vtt', relation: :transcript, file_set: file_set)
  #   Hyrax::Actors::FileSetActor.new(file_set, uploading_user).create_content(job_io, :transcript)
  #
  directly_contains_one :transcript, through: :files, type: ::RDF::URI('http://pcdm.org/use#Transcript'), class_name: 'Hydra::PCDM::File'

  # using our own FileSetIndexer that doesn't index full-text content
  self.indexer = Spot::FileSetIndexer
end
