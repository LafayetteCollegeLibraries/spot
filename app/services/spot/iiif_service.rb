# frozen_string_literal: true
require 'cgi'
require 'uri'

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
    # @return [String]
    # @see config/initializers/hyrax.rb
    def self.image_url(file_id, _base_url, size)
      new(file_id: file_id, base_url: ENV['IIIF_BASE_URL']).image_url(size: size)
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
      URI.join(base_url, file_set_id).to_s
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
      URI.join(base_url, "#{file_set_id}/#{region}/#{size}/#{rotation}/#{quality}.#{format}").to_s
    end

    # Generates a IIIF image URL for an item that will trigger a download
    #
    # @param [Hash] options
    # @option [String] filename (default: "#{file_set_id}.jpg")
    # @option [String] region (default: 'full')
    # @option [String] size (default: DEFAULT_SIZE)
    # @option [String] rotation (default: '0')
    # @option [String] quality (default: 'default')
    # @option [String] format (default: 'jpg')
    # @return [String]
    # @see https://cantaloupe-project.github.io/manual/4.1/endpoints.html#Response%20Content%20Disposition
    def download_url(filename: nil, format: 'jpg', **args)
      filename = "#{file_set_id}.#{format}" if filename.nil?
      base_url = image_url(format: format, **args)

      "#{base_url}?response-content-disposition=attachment%3B%20#{filename}"
    end

    # file_id will look like "abc123def/files/00000000-0000-0000-0000-000000000000", but all
    # we really need is the first part (the id of the file_set)
    #
    # @return [String]
    def file_set_id
      @file_set_id ||= CGI.unescape(file_id).split('/files/').first
    end
  end
end
