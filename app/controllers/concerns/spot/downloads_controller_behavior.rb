# frozen_string_literal: true
module Spot
  # Mixin to append behaviors to Hyrax::DownloadsController.
  #
  # @see config/initializers/spot_overrides.rb
  # @note this needs to be :prepend-ed to Hyrax::DownloadsController, as #load_file is defined there
  # @example
  #   Hyrax::DownloadsController.prepend(Spot::DownloadsControllerBehavior)
  #
  module DownloadsControllerBehavior
    # Testing handled in spec/features/download_transcripts_spec.rb
    #
    # Add support to download a FileSet's attached :transcript file.
    # To access, use the 'file=transcript' query string
    #
    # @example
    #   # get object
    #   curl -o some_original_file.mov http://repository/downloads/file_set_id
    #
    #   # get thumbnail
    #   curl -o some_original_file.thumbnail.jpg http://repository/downloads/file_set_id?file=thumbnail
    #
    #   # get transcript file
    #   curl -o some_original_file.vtt http://repository/downloads/file_set_id?file=transcript
    #
    # @return [ActiveFedora::File, nil]
    # :nocov:
    def load_file
      return super unless params[:file] == 'derivative'
      stream = Valkyrie::StorageAdapter.find(:av_source_s3).find_by(id: "8964ddd2-8b10-4b1e-b7a1-40683f810d95-access.mp3")
      stream.disk_path
    end
    # :nocov:
  end
end
