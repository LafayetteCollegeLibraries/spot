# frozen_string_literal: true
module Spot
  module IndexesRightsStatementsAndLabels
    def to_solr
      super.tap do |document|
        document['rights_statement_ssim'] = []
        document['rights_statement_label_ssim'] = []
        document['rights_statement_shortcode_ssim'] = []

        Array.wrap(resource.rights_statement).each do |original_uri|
          value = original_uri.to_s
          label = rights_service.label(value) { value }
          shortcode = rights_service.shortcode(value) { nil }

          document['rights_statement_ssim'] << value
          document['rights_statement_label_ssim'] << label
          document['rights_statement_shortcode_ssim'] << shortcode
        end
      end
    end

    def rights_service
      @rights_service ||= Hyrax.config.rights_statement_service_class.new
    end
  end
end
