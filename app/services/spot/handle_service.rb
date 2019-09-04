# frozen_string_literal: true
module Spot
  # Service used to create + update Handle identifiers and attach them to a work.
  # Uses the local Handle server's API to PUT CREATE/MODIFY
  class HandleService
    attr_reader :work

    def initialize(work)
      @work = work
    end

    def mint_or_update
      work_has_handle? ? update : mint
    end

    def mint
      # no-op for now
      # send_payload_for(action: :mint)
    end

    def update
      # no-op for now
      # send_payload_for(action: :update)
    end

    private

      # @return [Faraday::Client]
      def client
        @client ||= Faraday.new(url: handle_server_url)
      end

      # @return [String]
      def handle_id
        "#{prefix}/#{work.id}"
      end

      # @return [String]
      def handle_server_url
        ENV['HANDLE_SERVER_URL']
      end

      # @return [Array<String>]
      def payload(action:)
        verb = case action
               when :mint   then 'CREATE'
               when :update then 'MODIFY'
               else raise "Unknown Handle action: #{action.inspect}"
               end

        [
          # CREATE/MODIFY prefix/id
          "#{verb} #{handle_id}",

          # idx, type, ttl, permission, encoding, value
          "100 URL 86400 1110 UTF8 #{permalink_url}"
        ]
      end

      # @return [String]
      def permalink_url
        Rails.application.routes.url_helpers.handle_url(handle_id)
      end

      # @return [String]
      def prefix
        ENV['HANDLE_PREFIX']
      end

      # @return [void]
      # @todo authentication?
      # @todo update the record afterwards
      def send_payload_for(action:)
        body_content = payload(action: action)

        response = client.put do |req|
          req.url "/api/handles/#{handle_id}"
          req.headers['Content-Type'] = 'application/json'
          req.body = JSON.dump(body_content)
        end

        # this isn't where we want to stop we still need to
        # deal with the response: did everything go ok?
        # if so, update the item
        JSON.parse(response.body)
      end

      # @return [true, false]
      def work_has_handle?
        work.respond_to?(:identifiers) && work.identifiers.include?("hdl:#{handle_id}")
      end
  end
end
