# frozen_string_literal: true
#
# Helper methods to generate the s3 presigned URL for audio/video files
module AudioVisualHelper
  # @param [String] s3 key
  # @return [String] presigned URL
  def s3_url(key)
    client = Aws::S3::Client.new
    obj = Aws::S3::Object.new(bucket_name: ENV['AWS_BULKRAX_IMPORTS_BUCKET'], key: key, client: client)
    url = obj.presigned_url(:get, expires_in: 3600)
    url
  end
end