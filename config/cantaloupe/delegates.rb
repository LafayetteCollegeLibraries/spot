# frozen_string_literal: true
#
# Bare-bones CustomDelegate for local development. This is expecting the
# Hyrax derivatives path to be mounted at /spot/derivatives or defined on
# the Cantaloupe container using the DERIVATIVES_PATH env value.
class CustomDelegate
  attr_accessor :context
  # @param _options [Hash] Empty hash.
  # @return [String,nil] Absolute pathname of the image corresponding to the
  #                      given identifier, or nil if not found.
  #
  def filesystemsource_pathname(_options = {})
    raw_id = context['identifier']
    derivative_path = raw_id.scan(/..?/).join('/') + '-access.tif'
    full_path = ::File.join(ENV.fetch('DERIVATIVES_PATH', '/spot/derivatives'), derivative_path)

    full_path if ::File.exist?(full_path)
  end

  def authorize(_options = {})
    true
  end

  def extra_iiif2_information_response_keys(_options = {})
    {}
  end

  def redactions(_options = {})
    []
  end

  def source(_options = {}); end
  def azurestoragesource_blob_key(_options = {}); end
  def httpsource_resource_info(_options = {}); end
  def jdbcsource_database_identifier(_options = {}); end
  def jdbcsource_media_type(_options = {}); end
  def jdbcsource_lookup_sql(_options = {}); end
  def s3source_object_info(_options = {}); end
  def overlay(_options = {}); end
end
