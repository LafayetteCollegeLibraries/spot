# frozen_string_literal: true
module Spot
  module Derivatives
    # Thumbnail creation abstracted out from +Hyrax::FileSetDerivativesServices+.
    # Intended to be run as part of a subset within {Spot::ImageDerivativesService}
    # and needs to respond to :cleanup_derivatives and :create_derivatives (the
    # latter receives a source filename as a parameter).
    class ThumbnailService < BaseDerivativesService
      # @return [void]
      def cleanup_derivatives
        FileUtils.rm_f(derivative_path) if File.exist?(derivative_path)
      end

      # Creates a 200x150 ish thumbnail using the +hydra-derivatives+ gem
      #
      # @param [String, Pathname] filename
      # @return [void]
      def create_derivatives(filename)
        output_options = [
          {
            label: :thumbnail,
            format: 'jpg',
            size: '200x150>',
            url: derivative_url,
            layer: 0
          }
        ]

        Hydra::Derivatives::ImageDerivatives.create(filename, outputs: output_options)
      end

      private

        def derivative_path
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
        end

        # @return [String]
        def derivative_url
          URI("file://#{derivative_path}").to_s
        end
    end
  end
end
