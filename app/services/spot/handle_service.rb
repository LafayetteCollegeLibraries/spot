# frozen_string_literal: true
module Spot
  # Service used to create or update Handle identifiers and attach them to a work.
  class HandleService
    attr_reader :work

    class << self
      # @return [true, false]
      def env_values_defined?
        [handle_server_url, handle_prefix, handle_client_cert, handle_client_key].all?(&:present?)
      end

      def handle_client_cert
        ENV['HANDLE_CLIENT_CERT_PEM']
      end

      def handle_client_key
        ENV['HANDLE_CLIENT_KEY_PEM']
      end

      def handle_prefix
        ENV['HANDLE_PREFIX']
      end

      def handle_server_url
        ENV['HANDLE_SERVER_URL']
      end
    end

    def initialize(work)
      @work = work
    end

    # @return [String, nil]
    #   returns nil if the env values aren't defined, otherwise the handle id is returned
    def mint
      # no-op if we can't mint handles
      return unless self.class.env_values_defined?

      res = send_payload

      raise("Received error code minting handle [#{handle_id}]: #{res['responseCode']}") unless res['responseCode'] == 1

      update_work_identifier(handle: res['handle']) unless work_has_handle?

      res['handle']
    end

    private

    def find_handle_id
      stored = work.identifier.find { |id| id.start_with? 'hdl:' }
      return "#{self.class.handle_prefix}/#{work.id}" unless stored

      Spot::Identifier.from_string(stored).value
    end

    def handle_certificate
      cert_pem = self.class.handle_client_cert
      raise "HANDLE_CLIENT_CERT_PEM isn't present" if cert_pem.blank?

      OpenSSL::X509::Certificate.new(cert_pem)
    end

    # @return [String]
    def handle_id
      @handle_id ||= find_handle_id
    end

    def handle_key
      handle_key = self.class.handle_client_key
      raise "HANDLE_CLIENT_KEY_PEM isn't present" if handle_key.blank?

      OpenSSL::PKey.read(handle_key)
    end

    # @return [String]
    def permalink_url
      # need to use CGI.unescape as the slashes in our handle_id will be encoded by +handle_url+
      CGI.unescape(Rails.application.routes.url_helpers.handle_url(handle_id, host: ENV['URL_HOST']))
    end

    # @return [void]
    # @todo update the record afterwards
    def send_payload
      payload = {
        index: 100,
        type: 'URL',
        permissions: '1110',
        data: { format: 'string', value: permalink_url }
      }

      headers = {
        'Authorization' => 'Handle clientCert=true',
        'Content-Type' => 'application/json'
      }

      put_url = "#{self.class.handle_server_url.gsub(/\/$/, '')}/api/handles/#{handle_id}"
      response = Faraday.put(put_url, JSON.dump(payload), headers)

      # this isn't where we want to stop, we still need to
      # deal with the response: did everything go ok?
      # if so, update the item
      JSON.parse(response.body)
    end

    def update_work_identifier(handle:)
      work.identifier += [Spot::Identifier.new('hdl', handle).to_s]
      Hyrax.persister.save(resource: work)
    end

    # @return [true, false]
    def work_has_handle?
      work.respond_to?(:identifier) && work.identifier.any? { |id| id.start_with? 'hdl:' }
    end
  end
end
