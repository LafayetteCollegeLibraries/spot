# frozen_string_literal: true
#
# app/services/concerns/spot/retrieves_s3_urls.rb
module Spot
  # Mixin to add to BrowseEverything::Retriever for
  # retrieving `s3://` urls. BrowseEverything takes a configuration
  # option for S3 url :response_type, but Retriever doesn't know
  # how to handle them.
  #
  # This should be `.prepend` ed into the BrowseEverything::Retriever class
  # in an initializer.
  #
  # @example
  #   BrowseEverything::Retriever.prepend(Spot::RetrievesS3Urls)
  #
  module RetrievesS3Urls
    extend ActiveSupport::Concern

    module ClassMethods
      # :nocov:
      def can_retrieve?(uri, headers = {})
        uri_parsed = ::Addressable::URI.parse(uri)

        case uri_parsed.scheme
        when "s3"
          client = Aws::S3::Client.new
          resp = client.head_object(bucket: uri_parsed.host, key: uri_parsed.path[1..-1])
          return true unless resp.nil?
          false
        else
          super(uri, headers)
        end
      end
      # :nocov:
    end

    # :nocov:
    def retrieve(options, &block)
      download_options = extract_download_options(options)
      url = download_options[:url]

      case url.scheme
      when "s3"
        file_size = download_options[:file_size]
        retrieved = 0

        client = Aws::S3::Client.new
        begin
          client.get_object(bucket: url.host, key: url.path[1..-1]) do |chunk|
            retrieved += chunk.bytesize
            yield(chunk, retrieved, file_size)
          end
        rescue Aws::S3::Errors::ServiceError => e
          raise BrowseEverything::DownloadError.new("#{self.class}: Failed to download #{url}: Status Code: #{e.code}", e)
        end
      else
        super(options, &block)
      end
    end
    # :nocov:

    private

    # :nocov:
    def get_file_size(options)
      uri = options.fetch(:url)
      uri_parsed = ::Addressable::URI.parse(uri)

      case uri_parsed.scheme
      when "s3"
        client = Aws::S3::Client.new
        resp = client.head_object(bucket: uri_parsed.host, key: uri_parsed.path[1..-1])
        resp.content_length
      else
        super(options)
      end
    end
    # :nocov:
  end
end
