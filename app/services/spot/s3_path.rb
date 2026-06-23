# frozen_string_literal: true
module Spot
  # Path generators for the Valkyrie storage adapters. The default Valkyrie-Shrine
  # adapter combines the resource id with a generated uuid to prevent accidental
  # overwriting of files, but we're not concerned with that w/r/t source objects
  # for media playback; we just want the most recent derivative.
  #
  # This follows the API set with IdPathGenerator. As a hack, to generate a pathname
  # from a resource without an original filename available (say you're trying to access
  # an IIIF tif file but the original file is a jpg), passing a glob string to the
  # :original_filename parameter will use whatever extension is provided.
  #
  # @example Delete an existing IIIF access copy for a file_set
  #   file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: 'file_set__1')
  #   s3_identifier = Spot::S3Path::IiifPathGenerator.new.generate(resource: file_set, original_filename: '*.tif')
  #   adapter = Valkyrie::StorageAdapter.find(:iiif_source_s3)
  #   adapter.delete(id: s3_identifier)
  #
  # @see https://github.com/samvera-labs/valkyrie-shrine/blob/v1.0.0/lib/valkyrie/storage/shrine.rb#L14-L30
  # @see config/initializers/hyrax.rb
  module S3Path
    class Base
      def initialize(base_path: nil); end
    end

    # IIIF source images are created on disk before sending to S3,
    # so the desired filename has already been generated.
    class IiifPathGenerator < Base
      def generate(resource:, file:, original_filename:) # rubocop:disable Lint/UnusedMethodArgument
        "#{resource.id}-access#{File.extname(original_filename)}"
      end
    end

    # @todo get this from Jenn's work
    class AvPathGenerator < Base
      def generate(resource:, file:, original_filename:) # rubocop:disable Lint/UnusedMethodArgument
        "#{resource.id}-access#{File.extname(original_filename)}"
      end
    end
  end
end
