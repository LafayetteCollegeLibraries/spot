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

      # Creates a 200x150 ish thumbnail using MiniMagick. Forces the input into
      # an sRGB colorspace to address an issue with CMYK PDFs generating inverted
      # thumbnails.
      #
      # @param [String, Pathname] filename
      # @return [void]
      # @see https://github.com/LafayetteCollegeLibraries/spot/issues/831
      def create_derivatives(filename)
        output_dirname = File.dirname(derivative_path)
        FileUtils.mkdir_p(output_dirname) unless File.directory?(output_dirname)

        MiniMagick::Tool::Convert.new do |convert|
          convert << "#{filename}[0]"
          convert.merge! %w[-colorspace sRGB -flatten -resize 200x150> -format jpg]
          convert << derivative_path
        end
      end

      private

      def derivative_path
        Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail').to_s
      end
    end
  end
end
