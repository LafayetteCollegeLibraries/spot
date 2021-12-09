# frozen_string_literal: true
#
# Copied verbatim from the Hyrax source, with the only change being
# to use the FITSServlet tool if the 'FITS_SERVLET_URL' ENV value is found.
class CharacterizeJob < ::Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # Characterizes the file at 'filepath' if available, otherwise, pulls a copy from the repository
  # and runs characterization on that file.
  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    raise "#{file_set.class.characterization_proxy} was not found for FileSet #{file_set.id}" unless file_set.characterization_proxy?
    filepath = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id) unless filepath && File.exist?(filepath)
    characterize(file_set, file_id, filepath)
    CreateDerivativesJob.perform_later(file_set, file_id, filepath)
  end

private

  def characterize(file_set, _file_id, filepath)
    Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filepath, ch12n_tool: tool)
    Rails.logger.debug "Ran characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"

    alpha_channels(file_set) if file_set.image? && Hyrax.config.iiif_image_server?
    file_set.characterization_proxy.save!

    file_set.update_index
    file_set.parent&.in_collections&.each(&:update_index)
  end

  def channels(filepath)
    ch = MiniMagick::Tool::Identify.new do |cmd|
      cmd.format '%[channels]'
      cmd << filepath
    end
    [ch]
  end

  def alpha_channels(file_set)
    return unless file_set.characterization_proxy.respond_to?(:alpha_channels=)

    file_set.characterization_proxy.alpha_channels = channels(filepath)
  end

  def tool
    ENV['FITS_SERVLET_URL'].present? ? :fits_servlet : :fits
  end
end
