# frozen_string_literal: true
require 'cgi'
require 'uri'

module Spot
  class IiifService
    COMPLIANCE_LEVEL = 2
    COMPLIANCE_LEVEL_URI = 'http://iiif.io/api/image/2/level2.json'
    DEFAULT_SIZE = '600,'

    def self.image_url(file_id, base_url, size)
      new(file_id, base_url).image_url(size: size)
    end

    def self.info_url(file_id, base_url)
      new(file_id, base_url).info_url
    end

    attr_reader :file_id, :base_url

    def initialize(file_id, base_url: ENV['IIIF_URL_BASE'])
      @file_id = file_id
      @base_url = base_url
    end

    def info_url
      URI.join(base_url, file_set_id, 'info.json')
    end

    # :id/:region/:size/:rotation/:quality.:format
    def image_url(region: 'full', size: DEFAULT_SIZE, rotation: '0', quality: 'default', format: 'jpg')
      URI.join(base_url, file_set_id, region, size, rotation, "#{quality}.#{format}")
    end

    # file_id will look like "abc123def/files/00000000-0000-0000-0000-000000000000", but all
    # we really need is the first part (the id of the file_set)
    def file_set_id
      @file_set_id ||= CGI.unescape(file_id).split('/files/').first
    end
  end
end
