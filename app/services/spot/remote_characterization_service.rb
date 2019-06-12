# frozen_string_literal: true
#
# An alternative to running FITS locally: this sends the file to a
# Fits Servlet (see: https://github.com/harvard-lts/FITSservlet).
# Saves us the overhead of spinning up the FITS application every time
# we want to characterize an item.
#
# Relies on the ENV variable 'FITS_SERVLET_URL' being defined
# with the hostname (or ip address) + port of the Tomcat server
# providing the service.
#
# @example basic usage (see {CharacterizeJob})
#   fs = FileSet.find('abc123def')
#   working_path = Hyrax::WorkingDirectory.find_or_retrieve(fs.files.first.id, fs.id)
#   Spot::RemoteCharacterizationService.run(fs.characterization_proxy, working_path)
#   fs.characterization_proxy.save!
#   fs.update_index
#   fs.parent&.in_collections&.each(&:update_index)
#
require 'uri'

module Spot
  class RemoteCharacterizationService < ::Hydra::Works::CharacterizationService
    # Essentially the same process as Hydra::Works::CharacterizationService
    # but we're sending the file with Faraday, instead of reading the IO
    # contents + feeding it to FITS.
    #
    # @return [void]
    def characterize
      raise StandardError, 'No FITS_SERVLET_URL provided!' if fits_servlet_url.nil?

      terms = parse_metadata(extract_metadata)
      store_metadata(terms)
    end

    protected

      # @return [String] XML response from the FITS servlet
      def extract_metadata
        payload = { datafile: ::Faraday::UploadIO.new(source, 'application/octet/stream') }

        response = remote_connection.post(parsed_uri.path, payload)
        response.body.to_s
      end

      # @return [String]
      def fits_servlet_url
        ENV.fetch('FITS_SERVLET_URL') { nil }
      end

      # When creating a connection, Faraday will only use the scheme/host/port
      # portion of the URI. We need to access the path to make the POST
      # connection, so we'll cache the parsed URI here.
      #
      # @return [URI]
      def parsed_uri
        @parsed_url ||= URI(fits_servlet_url)
      end

      # @return [Faraday::Connection]
      def remote_connection
        ::Faraday.new(parsed_uri) do |f|
          f.request :multipart
          f.request :url_encoded
          f.adapter :net_http
        end
      end
  end
end
