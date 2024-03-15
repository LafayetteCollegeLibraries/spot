# frozen_string_literal: true
#
# Helper methods to generate the s3 presigned URL for audio/video files
module AudioVisualHelper
  # @param [String] s3 key
  # @return [String] presigned URL 
  def s3_url(key)
    client = Aws::S3::Client.new()
    obj = client.get_object(bucket: 'av-derivatives', key: key)
    url = obj.presigned_url(:get, expires_in: 3600)
    return url
  end
end
