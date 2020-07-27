# frozen_string_literal: true
#
# Bare-bones CustomDelegate for local development. This is expecting the
# rails tmp/derivatives path to be mounted at /image-root
# rubocop:disable Layout/EmptyLineBetweenDefs
class CustomDelegate
  ##
  # Attribute for the request context, which is a hash containing information
  # about the current request.
  #
  # This attribute will be set by the server before any other methods are
  # called. Methods can access its keys like:
  #
  # ```
  # identifier = context['identifier']
  # ```
  #
  # The hash will contain the following keys in response to all requests:
  #
  # * `client_ip`        [String] Client IP address.
  # * `cookies`          [Hash<String,String>] Hash of cookie name-value pairs.
  # * `identifier`       [String] Image identifier.
  # * `request_headers`  [Hash<String,String>] Hash of header name-value pairs.
  # * `request_uri`      [String] Public request URI.
  # * `scale_constraint` [Array<Integer>] Two-element array with scale
  #                      constraint numerator at position 0 and denominator at
  #                      position 1.
  #
  # It will contain the following additional string keys in response to image
  # requests:
  #
  # * `full_size`      [Hash<String,Integer>] Hash with `width` and `height`
  #                    keys corresponding to the pixel dimensions of the
  #                    source image.
  # * `operations`     [Array<Hash<String,Object>>] Array of operations in
  #                    order of application. Only operations that are not
  #                    no-ops will be included. Every hash contains a `class`
  #                    key corresponding to the operation class name, which
  #                    will be one of the `e.i.l.c.operation.Operation`
  #                    implementations.
  # * `output_format`  [String] Output format media (MIME) type.
  # * `resulting_size` [Hash<String,Integer>] Hash with `width` and `height`
  #                    keys corresponding to the pixel dimensions of the
  #                    resulting image after all operations have been applied.
  #
  # @return [Hash] Request context.
  #
  attr_accessor :context

  def authorize(options = {})
    true
  end

  def extra_iiif2_information_response_keys(options = {})
    {}
  end

  ##
  # Tells the server which source to use for the given identifier.
  #
  # @param options [Hash] Empty hash.
  # @return [String] Source name.
  #
  def source(_options = {}); end
  def azurestoragesource_blob_key(options = {}); end

  ##
  # N.B.: this method should not try to perform authorization. `authorize()`
  # should be used instead.
  #
  # @param options [Hash] Empty hash.
  # @return [String,nil] Absolute pathname of the image corresponding to the
  #                      given identifier, or nil if not found.
  #
  def filesystemsource_pathname(_options = {})
    raw_id = context['identifier']
    derivative_path = raw_id.scan(/..?/).join('/') + '-access.tif'
    full_path = ::File.join('/imageroot', derivative_path)

    full_path if ::File.exist?(full_path)
  end

  def httpsource_resource_info(_options = {}); end
  def jdbcsource_database_identifier(_options = {}); end
  def jdbcsource_media_type(_options = {}); end
  def jdbcsource_lookup_sql(_options = {}); end
  def s3source_object_info(_options = {}); end
  def overlay(_options = {}); end

  def redactions(_options = {})
    []
  end
end
# rubocop:enable Layout/EmptyLineBetweenDefs
