# frozen_string_literal: true
module Spot
  module Derivatives
    # Thumbnail creation for file_sets (except audio mime-types).
    #
    # @example
    #   working_copy = Hyrax::WorkingDirectory.find_or_retrieve(file_set)
    #   Spot::Derivatives::ThumbnailServkce.new(file_set).create_derivatives(working_copy)
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
      def create_derivatives(src_path)
        output_dirname = File.dirname(derivative_path)
        FileUtils.mkdir_p(output_dirname) unless File.directory?(output_dirname)

        MiniMagick::Tool::Convert.new do |convert|
          convert.merge!([
            "#{src_path}[0]",
            "-colorspace", "sRGB",
            "-flatten",
            "-resize", "200x150>",
            "-format", "jpg",
            derivative_path
          ])
        end
      end

      # Audio formats are the only ones we can't create a thumbnail for
      #
      # @return [true, false]
      def valid?
        !audio_mime_types.include?(mime_type)
      end

      private

      def derivative_path
        Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail').to_s
      end
    end
  end
end
