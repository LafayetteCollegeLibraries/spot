# frozen_string_literal: true
module Spot
  # Service for generating IIIF urls (via file_ids) for an external Cantaloupe image server.
  # Really, this could be used for _any_ external image server, save for the #download_url
  # method, which attaches the Cantaloupe-specific content-disposition query string.
  class IiifService
    COMPLIANCE_LEVEL = 2
    COMPLIANCE_LEVEL_URI = 'http://iiif.io/api/image/2/level2.json'
    DEFAULT_SIZE = '600,'

    # Class method to be used via Hyrax initializer for generating an image's IIIF URL.
    # We're not using the +base_url+ parameter provided and instead relying on
    # the default, which is the environment value for 'IIIF_BASE_URL'.
    #
    # @example adding to hyrax initializer
    #   Hyrax.config.iiif_image_url_builder = Spot::IiifService.method(:image_url)
    #
    # @param [String] file_id
    # @param [String] _base_url
    # @param [String] size
    # @param [String] format
    # @return [String]
    # @see config/initializers/hyrax.rb
    def self.image_url(file_id, _base_url, size, format:)
      kwargs = { size: size, format: format }.compact
      new(file_id: file_id, base_url: ENV['IIIF_BASE_URL']).image_url(**kwargs)
    end

    # Class method to be used via Hyrax initializer for generating an info.json URL.
    # We're not using the +base_url+ parameter provided and instead relying on
    # the default, which is the environment value for 'IIIF_BASE_URL'.
    #
    # @example adding to hyrax initializer
    #   Hyrax.config.iiif_image_url_builder = Spot::IiifService.method(:info_url)
    #
    # @param [String] file_id
    # @param [String] _base_url
    # @return [String]
    # @see config/initializers/hyrax.rb
    # @note this produces a URL _without_ the final 'info.json' of the path.
    #       Somewhere in the pipeline this is added (possibly by the viewer?)
    def self.info_url(file_id, _base_url)
      new(file_id: file_id, base_url: ENV['IIIF_BASE_URL']).info_url
    end

    # Class method for providing a download url (one where the content-disposition is set to 'attachment')
    #
    # @param [String] file_id
    # @param [String] size
    # @param [String] filename (must include extension)
    # @return [String]
    def self.download_url(file_id:, size:, filename:)
      new(file_id: file_id, base_url: ENV['IIIF_BASE_URL']).download_url(size: size, filename: filename)
    end

    attr_reader :file_id, :base_url

    def initialize(file_id:, base_url: ENV['IIIF_BASE_URL'])
      @file_id = file_id
      @base_url = base_url
      @base_url += '/' unless @base_url.end_with?('/')
    end

    # Generates a URL for getting an item's +info.json+ document
    #
    # @return [String]
    # @note this produces a URL _without_ the final 'info.json' of the path.
    #       Somewhere in the pipeline this is added (possibly by the viewer?)
    def info_url
      URI.join(base_url, asset_id).to_s
    end

    # Generates a IIIF image URL for an item
    #
    # @param [Hash] options
    # @option [String] region (default: 'full')
    # @option [String] size (default: DEFAULT_SIZE)
    # @option [String] rotation (default: '0')
    # @option [String] quality (default: 'default')
    # @option [String] format (default: 'jpg')
    # @return [String]
    def image_url(region: 'full', size: DEFAULT_SIZE, rotation: '0', quality: 'default', format: 'jpg')
      URI.join(base_url, "#{asset_id}/#{region}/#{size}/#{rotation}/#{quality}.#{format}").to_s
    end

    # Generates a IIIF image URL for an item that will trigger a download
    #
    # @param [Hash] options
    # @option [String] filename (default: "#{asset_id}.jpg")
    # @option [String] region (default: 'full')
    # @option [String] size (default: DEFAULT_SIZE)
    # @option [String] rotation (default: '0')
    # @option [String] quality (default: 'default')
    # @option [String] format (default: 'jpg')
    # @return [String]
    # @see https://cantaloupe-project.github.io/manual/4.1/endpoints.html#Response%20Content%20Disposition
    def download_url(filename: nil, format: 'jpg', **args)
      filename = "#{asset_id}.#{format}" if filename.nil?
      base_url = image_url(format: format, **args)

      "#{base_url}?response-content-disposition=attachment%3B%20#{filename}"
    end

    private

    # file_ids are generally "<file_set.id>/files/<af_file.id>" although
    # Valkyrized FileMetadata objects appear to have a fourth value after file id (version id?).
    # With ActiveFedora, we tied the file to the FileSet id, but with Valkyrie
    # we're using the FileMetadata id.
    #
    # @return [String]
    def asset_id
      @asset_id ||=
        if Hyrax.config.use_valkyrie?
          CGI.unescape(file_id).split('/')[2]
        else
          CGI.unescape(file_id).split('/files/').first
        end
    end
  end
end
