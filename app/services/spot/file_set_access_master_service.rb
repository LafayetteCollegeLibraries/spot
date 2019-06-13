# frozen_string_literal: true
#
# +Hyrax::FileSetDerivativesService+ already handles creating
# the thumbnail. We just want to create an access master for
# an image server to be able to retrieve.
#
# Note: for now we're going with pyramidal TIFs as a uniform
# format for our access masters. The community consensus seems
# to point to JPEG2000s or pyramidal TIFs as access masters.
# The former seems to require Kakadu (a paid software) to get
# the best results, while the later seems to be fairly standard.
#
# From https://mw2016.museumsandtheweb.com/paper/iiif-unshackle-your-images/:
#
# > If you want a free performant option, we would suggest the use
# > of Pyramidal TIFFs. When used in conjunction with a high-performance
# > image server, this format will give you the performance required
# > to implement IIIF.
#
# @example basic usage
#   fs = FileSet.find('abc123def')
#   working_dir = Hyrax::WorkingDirectory.new(fs.files.first.id, fs.id)
#   service = Spot::FileSetAccessMasterService.new(fs)
#   service.create_derivatives(working_dir)
#   File.exist?(Rails.root.join('tmp/derivatives/ab/c1/23/de/f-access.tif'))
#   # => true
#
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

    # Since we want to pass some extended options to the creation process,
    # we'll just use MiniMagick, rather than use
    # Hydra::Derviatives::ImageDerivatives.
    #
    # @param [String,Pathname] filename the src path of the file
    # @return [void]
    def create_derivatives(filename)
      MiniMagick::Tool::Magick.new do |magick|
        magick << filename
        # note: we need to use an array for each piece of this command;
        # using a string will cause an error
        magick.merge! %w[-define tiff:tile-geometry=128x128]
        magick << "ptif:#{derivative_url('access.tif')}"
      end
    end

    # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
    # but modifies the filename it writes out to.
    #
    # @param [String] destination_name
    # @return [String]
    def derivative_url(destination_name)
      derivative_path_factory
        .derivative_path_for_reference(file_set, destination_name)
        .to_s.gsub(%r{\.#{destination_name}$}, '')
    end

    # @return [true, false]
    def valid?
      file_set.class.image_mime_types.include? mime_type
    end

    private

      # @return [Class]
      def derivative_path_factory
        Hyrax::DerivativePath
      end
  end
end
