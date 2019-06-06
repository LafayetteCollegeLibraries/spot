# frozen_string_literal: true
#
# Alternate version of history where we use the FitsServlet service
# to characterize our works, rather than spinning up FITS for each
# item. This may help reduce overhead in the long run.
class CharacterizeJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Essentially this is the same as the Hyrax CharacterizeJob, except that
  # we'll use
  #
  # @param [FileSet] file_set
  # @param [String] file_id Identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  # @param [true, false] use_remote Override to prefer a local FITS service be spun up.
  def perform(file_set, file_id, filepath = nil, use_remote: true)
    @use_remote = use_remote

    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)

    characterization_service.run(file_set.characterization_proxy, filepath)
    Rails.logger.debug "Ran characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    file_set.characterization_proxy.save!
    file_set.update_index
    file_set.parent&.in_collections&.each(&:update_index)

    CreateDerivativesJob.perform_later(file_set, file_id, filepath)
  end

  private

    # @return [Class]
    def characterization_service
      return Spot::RemoteCharacterizationService if use_remote_service?

      Hydra::Works::CharacterizationService
    end

    # @return [true, false]
    def use_remote_service?
      @use_remote && ENV.include?('FITS_SERVLET_HOST')
    end
end
