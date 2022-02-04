# frozen_string_literal: true
module Spot
  module Derivatives
    # Creates access_master derivatives for all image-based works.
    # Intended to be run as part of a subset within {Spot::ImageDerivativesService}
    # and needs to respond to :cleanup_derivatives and :create_derivatives (the
    # latter receives a source filename as a parameter).
    class AccessMasterService < BaseDerivativesService
      # Deletes the local access_master derivative if it exists
      #
      # @return [void]
      def cleanup_derivatives
        FileUtils.rm_f(derivative_path) if File.exist?(derivative_path)
      end

      # Since we want to pass some extended options to the creation process,
      # we'll just use MiniMagick, rather than use
      # Hydra::Derviatives::ImageDerivatives.
      #
      # @param [String,Pathname] filename the src path of the file
      # @return [void]
      def create_derivatives(filename)
        output_dirname = File.dirname(derivative_path)
        FileUtils.mkdir_p(output_dirname) unless File.directory?(output_dirname)

        MiniMagick::Tool::Convert.new do |magick|
          magick << "#{filename}[0]"
          # note: we need to use an array for each piece of this command;
          # using a string will cause an error
          magick.merge! %w[-define tiff:tile-geometry=128x128 -compress jpeg]
          magick << "ptif:#{derivative_path}"
        end
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def derivative_path
        Hyrax::DerivativePath
          .derivative_path_for_reference(file_set, 'access.tif')
          .to_s.gsub(%r{\.#{'access.tif'}$}, '')
      end
    end
  end
end
