# frozen_string_literal: true
#
# Helper methods to generate the s3 presigned URL for audio/video files
module AudioVisualHelper
  # @param [String] s3 key
  # @return [String] presigned URL
  # @note For development environments, we need to subsitute the service hostname of S3 ('minio')
  #       with 'localhost' for links to resolve. In production, 'AWS_ENDPOINT_URL's hostname is valid.
  def s3_url(key)
    if ENV['AWS_ENDPOINT_URL'].blank?
      Rails.logger.warn('AWS_ENDPOINT_URL environment variable is not defined.')
      return ""
    end
    client = Aws::S3::Client.new()
    begin
      client.head_object(key: key, bucket: ENV['AWS_AV_ASSET_BUCKET'])
    rescue Aws::S3::Errors::NotFound
      Rails.logger.warn('S3: Key not found.')
      return ""
    end
    if Rails.env.development?
      client_opts = {}
      client_opts = { endpoint: ENV['AWS_ENDPOINT_URL'].sub('minio', 'localhost') }
      client = Aws::S3::Client.new(**client_opts)
    end
    obj = Aws::S3::Object.new(bucket_name: ENV['AWS_AV_ASSET_BUCKET'], key: key, client: client)
    url = obj.presigned_url(:get, expires_in: 3600)
    url
  end

  def get_original_name(presenters, derivative)
    presenters.each do |presenter|
      if presenter.id.to_s == derivative.split("-")[0]
        return presenter.original_filenames[0]
      end
    end
    return ""
  end

  def get_derivative_list(file_set)
    file_set.parent.stored_derivatives.to_a
  end

  def get_derivative_res(derivative)
    ret = derivative.split('-').last
    ret = ret.split('.')[0]
    ret
  end
end
