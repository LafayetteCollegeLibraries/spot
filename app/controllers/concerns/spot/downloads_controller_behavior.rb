# frozen_string_literal: true
module Spot
  # Mixin to append behaviors to Hyrax::DownloadsController.
  #
  # @see config/initializers/spot_overrides.rb
  module DownloadsControllerBehavior
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
    def load_file
      return super unless params[:file] == 'transcript'
      pcdm_file = dereference_file(params[:file]).find_target
      ActiveFedora::File.find(pcdm_file.id) if pcdm_file&.id
    end
  end
end
