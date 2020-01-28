# frozen_string_literal: true
module Spot
  # Service to tell Riiif about where we're storing access copies of our works
  # to be served by the image server.
  #
  # @example Using in Riiif initializer
  #   # config/initializers/riiif.rb
  #   Riiif::Image.file_resolver = Spot::ImageServerFileResolver.new
  #
  class ImageServerFileResolver < ::Riiif::FileSystemFileResolver
    def initialize(base_path: rails_derivatives_base)
      super(base_path: base_path)
    end

    # Creates a glob pattern for an ID
    #
    # @example
    #   id = "p5547r367/files/b7ccfea9-fa64-437f-87de-ab6ebcdf0cce"
    #   Spot::ImageServerFileResolver.new.pattern(id)
    #   # => "/path/to/rails_root/tmp/derivatives/p5/54/7r/36/7-access.{png,jpg,tif,tiff,jp2}"
    #
    # @param [String] id
    # @return [String] glob pattern for asset
    def pattern(id)
      clean_id = id.sub(/\A([^\/]*)\/.*/, '\1')
      return unless validate_identifier(id: clean_id)

      self.base_path = Pathname.new(base_path) unless base_path.is_a? Pathname
      base_path.join(access_copy_path(clean_id)).to_s
    end

    private

      # Turns an ID into a pair-tree path to the access copy.
      #
      # @param [String] id
      # @return [String] pair-tree path for ID
      def access_copy_path(id)
        id.scan(/\w\w?/).join('/') + "-access.{#{input_types.join(',')}}"
      end

      def identifier_regex
        /^[\w\d]+$/
      end

      def rails_derivatives_base
        Rails.root.join('tmp', 'derivatives')
      end
  end
end
