# frozen_string_literal: true
#
# Helper methods to generate the s3 presigned URL for audio/video files
module AudioVisualHelper
  # @param [String] s3 key
  # @return [String] presigned URL
  # @note For development environments, we need to subsitute the service hostname of S3 ('minio')
  #       with 'localhost' for links to resolve. In production, 'AWS_ENDPOINT_URL's hostname is valid.
  def s3_url(key)
    client_opts = {}
    client_opts = { endpoint: ENV['AWS_ENDPOINT_URL']&.sub('minio', 'localhost') } if Rails.env.development?
    client = Aws::S3::Client.new(**client_opts)
    obj = Aws::S3::Object.new(bucket_name: ENV['AWS_BULKRAX_IMPORTS_BUCKET'], key: key, client: client)
    url = obj.presigned_url(:get, expires_in: 3600)
    url
  end
end
