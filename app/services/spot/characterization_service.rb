# frozen_string_literal: true

# Ensures that our Fits XML contains valid UTF-8 characters, otherwise
# we'll get complaints from +xml.present?+
Hydra::Works::CharacterizationService.class_eval do
  def extract_metadata(content)
    Hydra::FileCharacterization.characterize(content, file_name, tools) do |cfg|
      cfg[:fits] = Hydra::Derivatives.fits_path
    end.encode('UTF-8', invalid: :replace)
  end
end

module Spot
  # A local version of the tasks found within Hyrax's +CharacterizeJob+,
  # but split out into a local service so that we can:
  #
  # a) build out specs to ensure that this works as expected
  # b) prefer using the FitsServlet when present
  # c) strip out invalid UTF-8 characters from the file_title and/or file_authors
  #
  # @example
  #   file_set = FileSet.find('abc123def')
  #   file_id = file_set.characterization_proxy.id
  #   file_path = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id)
  #   Spot::CharacterizationService.perform(file_set, file_id, file_path)
  #
  class CharacterizationService
    # Shorthand to initialize the service + perform characterization
    #
    # @param [FileSet] file_set
    # @param [String] file_id
    # @param [String] filepath
    def self.perform(file_set, file_id, filepath = nil)
      new(file_set, file_id, filepath).perform
    end

    # @param [FileSet] file_set
    # @param [String] file_id
    # @param [String] filepath
    def initialize(file_set, file_id, filepath = nil)
      @file_set = file_set
      @file_id = file_id
      @filepath = determine_filepath(filepath)
    end

    # Runs the characterization of the file and removes invalid UTF-8 characters
    # before saving the file and updating the index.
    #
    # @return [void]
    def perform
      characterization_service.characterize
      cleanup_proxy_values!

      proxy.save!
      Rails.logger.debug "Ran characterization on #{proxy.id} (#{proxy.mime_type})"
      @file_set.update_index
      @file_set.parent&.in_collections&.each(&:update_index)
    end

    private

      # If the environment variable +FITS_SERVLET_URL+ is present, we'll use
      # the +FitsServlet+ characterization tool. We'll fall-back to the command-line
      # version otherwise.
      #
      # @return [Hydra::Works::CharacterizationService]
      def characterization_service
        tool = fits_url_present? ? :fits_servlet : :fits
        Hydra::Works::CharacterizationService.new(proxy, @filepath, ch12n_tool: tool)
      end

      # Loops through known-problematic fields and removes invalid UTF-8 characters
      #
      # @return [void]
      def cleanup_proxy_values!
        [:creator, :file_title].each do |field|
          values = proxy.send(field).map { |v| v.encode('UTF-8', invalid: :replace, replace: '') }
          proxy.send(:"#{field}=", values)
        end
      end

      # Where's the file we're going to process located?
      #
      # @param [String, nil] path
      # @return [String]
      def determine_filepath(path)
        return path if path.present? && File.exist?(path)
        Hyrax::WorkingDirectory.find_or_retrieve(proxy.id, @file_set.id)
      end

      # @return [true, false]
      def fits_url_present?
        ENV['FITS_SERVLET_URL'].present?
      end

      # @return [Hydra::PCDM::File]
      def proxy
        @file_set.characterization_proxy
      end
  end
end
