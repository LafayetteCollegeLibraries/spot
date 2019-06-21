# frozen_string_literal: true
module Spot
  class UnpaywallSearchController < ::ApplicationController
    def search
      render json: parsed_results
    end

    private

      # @return [Hash<Symbol => String, Array<String>, nil>]
      def parsed_results
        results = search_service.find(params[:doi])

        return { error: 'No OA option found' } if results['best_oa_location'].blank?

        payload_from_search_results(results)
      rescue DOINotFound
        { error: 'DOI not found' }
      rescue => e
        { error: 'An unknown error occurred', message: e.message }
      end

      # @param [Array<Hash<String => String>>]
      # @return [Array<String>]
      def parse_authors(authors)
        Array.wrap(authors)&.map { |a| [a['family'], a['given']].reject(&:blank?).join(', ') }
      end

      # @return [String, nil]
      # rubocop:disable Metrics/CyclomaticComplexity
      def parse_rights_statement(res)
        case res['best_oa_location']['license']
        when 'cc-mark'     then 'http://creativecommons.org/publicdomain/mark/1.0/'
        when 'cc-zero'     then 'http://creativecommons.org/publicdomain/zero/1.0/'
        when 'cc-by'       then 'http://creativecommons.org/licenses/by/4.0/'
        when 'cc-by-sa'    then 'http://creativecommons.org/licenses/by-sa/4.0/'
        when 'cc-by-nd'    then 'http://creativecommons.org/licenses/by-nd/4.0/'
        when 'cc-by-nc'    then 'http://creativecommons.org/licenses/by-nc/4.0/'
        when 'cc-by-nc-sa' then 'http://creativecommons.org/licenses/by-nc-sa/4.0/'
        when 'cc-by-nc-nd' then 'http://creativecommons.org/licenses/by-nc-nd/4.0/'
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      # @return [Hash<Symbol => String, Array<String>, nil>]
      def payload_from_search_results(res)
        {
          creators: parse_authors(res['z_authors']),
          date_issued: res['published_date'],
          download_url: res['best_oa_location']['url_for_pdf'],
          journal_name: res['journal_name'],
          issn: res['journal_issns'],
          publisher: res['publisher'],
          rights_statement: parse_rights_statement(res),
          title: res['title']
        }
      end

      # @return [Class]
      def search_service
        UnpaywallSearchService
      end
  end
end
