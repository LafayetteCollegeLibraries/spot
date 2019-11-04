# frozen_string_literal: true
class CharacterizeJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Does the work of the same job found in Hyrax, but offloads it
  # to a service that we can test (+ keeps the job leaner).
  #
  # @param [FileSet] file_set
  # @param [String] file_id Identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    Spot::CharacterizationService.perform(file_set, file_id, filepath)
    CreateDerivativesJob.perform_later(file_set, file_id, filepath)
  end
end
