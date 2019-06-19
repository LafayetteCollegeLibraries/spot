# frozen_string_literal: true
module Spot
  class UnpaywallSearchController < ::ApplicationController
    def search
      render json: parsed_results
    end

    private

      def parsed_results
        results = search_service.find(params[:doi])
        puts results.inspect

        return { error: 'No OA option found' } if results['best_oa_location'].blank?

        {
          creators: parse_authors(results),
          date_issued: results['published_date'],
          download_url: results['best_oa_location']['url_for_pdf'],
          journal_name: results['journal_name'],
          issn: results['journal_issns'],
          publisher: results['publisher'],
          rights_statement: parse_rights_statement(results),
          title: results['title']
        }
      rescue DOINotFound
        { error: 'DOI not found' }
      rescue => e
        { error: 'An unknown error occurred', message: e.message }
      end

      def parse_authors(res)
        res['z_authors']&.map { |a| [a['family'], a['given']].reject(&:blank?).join(', ') }
      end

      def parse_rights_statement(res)
        case res['best_oa_location']['license']
        when 'cc-mark'
          'http://creativecommons.org/publicdomain/mark/1.0/'
        when 'cc-zero'
          'http://creativecommons.org/publicdomain/zero/1.0/'
        when 'cc-by'
          'http://creativecommons.org/licenses/by/4.0/'
        when 'cc-by-sa'
          'http://creativecommons.org/licenses/by-sa/4.0/'
        when 'cc-by-nd'
          'http://creativecommons.org/licenses/by-nd/4.0/'
        when 'cc-by-nc'
          'http://creativecommons.org/licenses/by-nc/4.0/'
        when 'cc-by-nc-sa'
          'http://creativecommons.org/licenses/by-nc-sa/4.0/'
        when 'cc-by-nc-nd'
          'http://creativecommons.org/licenses/by-nc-nd/4.0/'
        else
          nil
        end
      end

      def search_service
        UnpaywallSearchService
      end
  end
end
