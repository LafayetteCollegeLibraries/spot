# frozen_string_literal: true
#
# Helper methods to generate the s3 presigned URL for audio/video files
module AudioVisualHelper
  # @param [String] s3 key
  # @return [String] presigned URL
  # @note For development environments, we need to subsitute the service hostname of S3 ('minio')
  #       with 'localhost' for links to resolve. In production, 'AWS_ENDPOINT_URL's hostname is valid.
  def s3_url(key)
    client = Aws::S3::Client.new
    begin
      client.head_object(key: key, bucket: ENV['AWS_AV_ASSET_BUCKET'])
    rescue Aws::S3::Errors::NotFound
      Rails.logger.warn('S3: Key not found.')
      return "S3: Key not found."
    end
    if Rails.env.development?
      if ENV['AWS_ENDPOINT_URL'].blank?
        Rails.logger.warn('AWS_ENDPOINT_URL environment variable is not defined.')
        return "AWS_ENDPOINT_URL environment variable is not defined."
      end
      client_opts = { endpoint: ENV['AWS_ENDPOINT_URL'].sub('minio', 'localhost') }
      client = Aws::S3::Client.new(**client_opts)
    end
    obj = Aws::S3::Object.new(bucket_name: ENV['AWS_AV_ASSET_BUCKET'], key: key, client: client)
    url = obj.presigned_url(:get, expires_in: 3600)
    url
  end

  # Matches fileset ids with their presenters and returns their original file names for audio playlist
  # @param presntres [[FileSetPresenter]] list of file set presenters attactched to a work
  # @param derivative [String] a particular derivative key to be matched with a presenter
  # @return [String] the original file name of the given derivative
  def get_original_name(presenters, derivative)
    presenter = presenters.find { |p| p.id.to_s == derivative.split('-').first }
    return '' if presenter.blank?

    presenter.original_filenames.first
  end

  # @param file_set [FileSet] a fileset from the view
  # @return [String] a list of associated derivatives of the work
  def get_derivative_list(presenters)
    presenters.flat_map(&:stored_derivatives)
  end

  # @param derivative [String] a particular derivative key
  # @return [String] the height of the derivative video
  # @example
  #   get_derivative_res('project/project_example_derivative-480.mp4')
  #   #=> '480'
  def get_derivative_res(derivative)
    File.basename(derivative, '.*').split('-').last
  end

  # @return the network path to the transcript
  # @param [FileSet] file_set of the video
  def transcript_path(file_set)
    Hyrax::Engine.routes.url_helpers.download_path(id: file_set.id, file: 'transcript')
  end

  def deriv_for_fileset(file_set)
    stream = Valkyrie::StorageAdapter.find(:av_source_s3).find_by(id: shrine_id_for_fileset(file_set))
    stream_file_uri(stream)
  end

  def shrine_id_for_fileset(file_set)
    # id=file_set.id.to_s
    # id+= "-access.mp3"
    "0957c3e3-9f94-4ecb-8a45-2057cc897c50-access.mp3"
  end

  def stream_file_uri(stream_file)
    disk = stream_file.disk_path.to_s
    uri = URI.join(request.base_url, disk)
    uri.to_s
  end
end
