# frozen_string_literal: true
module Spot
  # Patch to add an s3 file matcher to remotely fetch files from s3 without a Browse Everything UI.
  # This is based on the remote files matcher in the application matcher but assumes a file path
  # (on s3) is provided rather than a url. The url is fetched in the same manner as AV s3 urls.
  #
  # @see spec/matchers/bulkrax/application_matcher_spec.rb (for related specs)
  # @see config/initializers/spot_overrides.rb (for inclusion)
  # @see https://github.com/samvera/bulkrax/blob/5e85a0760e9cc317ae11dbecd35c508d6882a5b6/app/matchers/bulkrax/application_matcher.rb#L58C5-L63C8
  module BulkraxS3FilesMatcher
    extend ActiveSupport::Concern

    def parse_s3_files(src)
      return if src.blank?
      src.strip!

      client = Aws::S3::Client.new
      begin
        client.head_object(key: src, bucket: ENV['AWS_BULKRAX_IMPORTS_BUCKET'])
      rescue Aws::S3::Errors::NotFound
        Rails.logger.warn('S3: Key not found.')
        return "S3: Key not found."
      end
      obj = Aws::S3::Object.new(bucket_name: ENV['AWS_BULKRAX_IMPORTS_BUCKET'], key: src, client: client)
      url = obj.presigned_url(:get, expires_in: 3600)

      name = src.split('/')[-1]
      { url: url, file_name: name }
    end
  end
end