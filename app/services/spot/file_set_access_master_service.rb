# frozen_string_literal: true
module Spot
  class FileSetAccessMasterService
    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    # @param [FileSet] file_set
    def initialize(file_set)
      @file_set = file_set
    end

    # @return [void]
    def cleanup_derivatives
      derivative_path_factory.derivatives_for_reference(file_set).each do |path|
        FileUtils.rm_f(path)
      end
    end

    # +Hyrax::FileSetDerivativesService+ already handles creating
    # the thumbnail. We just want to create an access_master for
    # an image server to be able to retrieve.
    #
    # @param [String,Pathname] filename
    # @return [void]
    def create_derivatives(filename)
      Hydra::Derivatives::ImageDerivatives.create(filename, outputs: access_master_outputs)
    end

    # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
    # but modifies the filename it writes out to.
    #
    # @param [String] destination_name
    # @return [String]
    def derivative_url(destination_name)
      path = derivative_path_factory.derivative_path_for_reference(file_set, destination_name)

      # +#derivative_path_for_reference+ will duplicate the destination name by default,
      # resulting in "/path/to/derivatives/ab/cd/ef/gh/i-access.jpg.access.jpg"
      URI("file://#{path}").to_s.gsub(%r{\.#{destination_name}$}, '')
    end

    # @return [true, false]
    def valid?
      file_set.class.image_mime_types.include? mime_type
    end

    private

      # @return [Array<Hash>]
      def access_master_outputs
        [{
          label: :access,
          format: 'jpg',
          url: derivative_url('access.jpg'),
          layer: 0
        }]
      end

      # @return [Class]
      def derivative_path_factory
        Hyrax::DerivativePath
      end
  end
end
